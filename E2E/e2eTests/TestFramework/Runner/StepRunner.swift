import Foundation

class StepRunner {
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
                
                throw TestFramework.Failure.stepParameterDoesNotMatch(
                    step: stepDefinition,
                    expected: String(describing: T.self),
                    actual: String(describing: actualType)
                )
            }
            return try await callback(typedInput)
        }
        self.stepMatcher = StepRunner.createMatcher(stepDefinition)
        self.parsers = StepRunner.createParsers(stepDefinition)
    }
    
    private static func createMatcher(_ stepDefinition: String) -> String {
        return stepDefinition.replacingOccurrences(of: StepRunner.parameterPattern, with: "(.*)", options: .regularExpression)
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
            let regex = try NSRegularExpression(pattern: StepRunner.parameterPattern, options: [])
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
            fatalError("Unable to get parameters type")
        }
    }
    
    func invoke<T>(parameters: T) async throws {
        try await callback(parameters)
    }
}
