import Foundation

struct StepRegistry {

    static var runnableSteps: [String : StepRunner] = [:]
    
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
            throw TestFramework.Failure.stepNotFound(step: step)
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
        let runnableStep = StepRunner(stepDefinition, callback)
        runnableSteps[runnableStep.stepMatcher] = runnableStep
    }
}
