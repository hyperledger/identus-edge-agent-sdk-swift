import Foundation
import XCTest
import Logging

class CucumberLite: XCTestCase {
    private static var actors: [String: Actor] = [:]
    
    override func setUp() {
        CucumberLite.addActor("Cloud Agent")
        CucumberLite.addActor("Edge Agent")
    }
    
    override class func tearDown() {
        actors = [:]
    }
    
    private static func addActor(_ name: String) {
        actors[name] = Actor(name)
    }
    
    static func asInt(_ value: String) -> Int {
        return Int(value)!
    }
    
    static func asActor(_ name: String) -> Actor {
        return self.actors[name]!
    }
}

class Actor {
    var name: String
    private var context: [String: Any] = [:]
    
    init(_ name: String) {
        self.name = name
    }
    
    func remember(key: String, value: Any) {
        print("        ", "Remembers", value)
        context[key] = value
    }
    
    func recall<T>(key: String) -> T {
        print("        ", "Recalls", key)
        XCTAssert(context[key] != nil, "Unable to recall [\(key)] all I know is \(context.keys)")
        return context[key] as! T
    }
}

class Scenario {
    var scenario: String
    private var stepList: [StepInstance] = []
    
    init(scenario: String) {
        self.scenario = scenario
    }
    
    private func step(context: String, step: String) {
        let stepInstance = StepInstance()
        stepInstance.context = context
        stepInstance.step = step
        stepList.append(stepInstance)
    }
    
    func given(_ step: String) {
        self.step(context: "Given", step: step)
    }
    
    func when(_ step: String) {
        self.step(context: "When", step: step)
    }
    
    func then(_ step: String) {
        self.step(context: "Then", step: step)
    }
    
    func run() async throws {
        print("--------------------------------")
        print(scenario)

        var lastContext = ""
        for step in stepList {
            print("    ", step.context == lastContext ? "And" : step.context, step.step)
            lastContext = step.context
            try await StepRegistry.run(step.step)
        }
    }
    
    func instrumented<T>(parameters: T, callback: @escaping (T) -> ()) {
        callback(parameters)
    }
}

class StepInstance {
    var context: String = ""
    var step: String = ""
}

@propertyWrapper
struct Parser<T> {
    var wrappedValue: (String) -> T
    var function: String
    
    init(wrappedValue: @escaping (String)  -> T, _ function: String) {
        self.wrappedValue = wrappedValue
        self.function = function
        ParserRegistry.annotatedMethods[function] = wrappedValue
    }
}

struct StepRegistry {
    typealias Zero = ()
    typealias One = (String)
    typealias Two = (String, String)
    typealias Three = (String, String, String)
    
    
    private static var parameterPattern = "\\{\\}"
    static var runnableSteps: [String : RunnableStep] = [:]
    
    static func run(_ step: String) async throws {
        var parameters: [String] = []
        var matchedStep: String?
        
        for stepMatcher in runnableSteps.keys {
            if let regex = try? NSRegularExpression(pattern: stepMatcher, options: []) {
                let range = NSRange(step.startIndex..., in: step)
                regex.enumerateMatches(in: step, options: [], range: range) { (match, _, _) in
                    if let match = match {
                        matchedStep = stepMatcher
                        for i in 1..<match.numberOfRanges {
                            let range = Range(match.range(at: i), in: step)!
                            let value = String(step[range])
                            parameters.append(value)
                        }
                    }
                }
            }
        }
        
        if (matchedStep == nil) {
            return
        }
        
        switch(parameters.count) {
        case 0:
            try await runnableSteps[matchedStep!]!.invoke(parameters: ())
        case 1:
            var parameter: One
            parameter = parameters[0]
            try await runnableSteps[matchedStep!]!.invoke(parameters: parameter)
        case 2:
            var parameter: Two
            parameter.0 = parameters[0]
            parameter.1 = parameters[1]
            try await runnableSteps[matchedStep!]!.invoke(parameters: parameter)
        case 3:
            var parameter: Three
            parameter.0 = parameters[0]
            parameter.1 = parameters[1]
            parameter.2 = parameters[2]
            try await runnableSteps[matchedStep!]!.invoke(parameters: parameter)
        default:
            print("Error")
        }
    }
    
    func instrumented<T>(parameters: Any, callback: @escaping (T) async throws -> ()) async throws {
        try await callback(parameters as! T)
    }
    
    static func addStep<T>(_ stepDefinition: String, callback: @escaping (T) async throws -> ()) {
        // creates matchable step
        let stepMatcher = stepDefinition.replacingOccurrences(of: parameterPattern, with: "(.*)", options: .regularExpression)
        runnableSteps[stepMatcher] = RunnableStep(stepMatcher, callback)
    }
}

class RunnableStep {
    private let callback: Any
    let matcher: String
    
    init(_ matcher: String, _ callback: Any) {
        self.matcher = matcher
        self.callback = callback
    }
    
    func invoke<T>(parameters: T) async throws {
        try await (callback as! ((T) async throws -> ()))(parameters)
    }
}

struct ParserRegistry {
    static var annotatedMethods: [String: (String) -> Any] = [:]
    
    static func parse(value: String, parser: String) -> Any {
        return annotatedMethods[parser]!(value)
    }
}

@propertyWrapper
class Step<T> {
    var step: String
    var callback: (T) async throws -> ()
    var wrappedValue: () async throws -> () {
        get {
            return {}
        }
    }

    init(wrappedValue: @escaping (T) async throws -> (), _ step: String) {
        self.callback = wrappedValue
        self.step = step
        StepRegistry.addStep(step, callback: callback)
    }
}
