
import Foundation

class StepInstance {
    var context: String = ""
    var step: String = ""
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

struct StepRegistry {

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
            throw CucumberError.stepNotFound(step: step)
        }
        
        let runnable = runnableSteps[matchedStep!]!
        let parsers = runnable.parsers

        switch(parameters.count) {
        case 0:
            try await runnableSteps[matchedStep!]!.invoke(parameters: ())
        case 1:
            let parameter = try await parsers[0](parameters[0])
            try await runnable.invoke(parameters: parameter)
        case 2:
            let parameter = (
                try await parsers[0](parameters[0]),
                try await parsers[1](parameters[1])
            )
            try await runnableSteps[matchedStep!]!.invoke(parameters: parameter)
        case 3:
            let parameter = (
                try await parsers[0](parameters[0]),
                try await parsers[1](parameters[1]),
                try await parsers[2](parameters[2])
            )
            try await runnableSteps[matchedStep!]!.invoke(parameters: parameter)
        default:
            fatalError("Seems you want to have more than 3 arguments, implement that case in Step class")
        }
    }

    static func addStep<T>(_ stepDefinition: String, callback: @escaping (T) async throws -> ()) {
        let runnableStep = RunnableStep(stepDefinition, callback)
        runnableSteps[runnableStep.stepMatcher] = runnableStep
    }
}

class RunnableStep {
    private let callback: (Any) async throws -> ()
    let stepDefinition: String
    var stepMatcher: String
    var parsers: [(String) async throws -> Any]
    
    private static var parameterPattern = "\\{([^}]*)\\}"

    init<T>(_ stepDefinition: String, _ callback: @escaping (T) async throws -> ()) {
        self.stepDefinition = stepDefinition
        self.callback = { input in
            guard let typedInput = input as? T else {
                let mirror = Mirror(reflecting: input)
                let actualType: String =
                if (String(describing: mirror.displayStyle!) == "tuple") {
                    "(" + mirror.children.map { String(describing: type(of: $0.value)) }.joined(separator: ", ") + ")"
                } else {
                    String(describing: mirror.subjectType)
                }
                
                throw CucumberError.stepParameterDoesNotMatch(
                    step: stepDefinition,
                    expected: String(describing: T.self),
                    actual: String(describing: actualType)
                )
            }
            return try await callback(typedInput)
        }
        self.stepMatcher = RunnableStep.createMatcher(stepDefinition)
        self.parsers = RunnableStep.createParsers(stepDefinition)
    }
    
    private static func createMatcher(_ stepDefinition: String) -> String {
        return stepDefinition.replacingOccurrences(of: RunnableStep.parameterPattern, with: "(.*)", options: .regularExpression)
    }
    
    private static func createParsers(_ stepDefinition: String) -> [(String) async throws -> Any] {
        var parsers: [(String) async throws -> Any] = []
        for parser in getStepParameterTypes(from: stepDefinition) {
            let method = ParserRegistry.annotatedMethods[parser.uppercased()]!
            parsers.append(method)
        }
        return parsers
    }
    
    private static func getStepParameterTypes(from text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: RunnableStep.parameterPattern, options: [])
            let nsString = NSString(string: text)
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

            return matches.map { match in
                let range = match.range(at: 1)
                if range.location != NSNotFound {
                    let parser = nsString.substring(with: range)
                    return parser.isEmpty ? "string" : parser
                } else {
                    return "string"
                }
            }
        } catch {
            CucumberLogger.error("Unable to get any parameter")
            return []
        }
    }
    
    func invoke<T>(parameters: T) async throws {
        try await callback(parameters)
    }
}
