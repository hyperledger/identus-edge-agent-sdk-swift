//
//  File.swift
//  
//
//  Created by io on 22/11/23.
//

import Foundation

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
