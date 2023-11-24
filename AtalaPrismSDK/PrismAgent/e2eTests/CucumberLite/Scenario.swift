import Foundation

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
