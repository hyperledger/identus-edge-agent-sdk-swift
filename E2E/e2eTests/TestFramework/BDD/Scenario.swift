import Foundation
import XCTest

class Scenario {
    let id = UUID().uuidString
    var title: String
    var steps: [StepInstance] = []
    var pass: Bool = false
    var error: Error? = nil
    
    private var lastContext: String = ""
    
    init(_ title: String) {
        self.title = title
    }
    
    func fail() {
        XCTFail()
    }

    private func addStep(_ step: String) {
        let stepInstance = StepInstance()
        stepInstance.context = lastContext
        stepInstance.step = step
        steps.append(stepInstance)
    }
    
    func given(_ step: String) -> Scenario {
        lastContext = "Given"
        addStep(step)
        return self
    }
    
    func when(_ step: String) -> Scenario {
        lastContext = "When"
        addStep(step)
        return self
    }
    
    func then(_ step: String) -> Scenario {
        lastContext = "Then"
        addStep(step)
        return self
    }
    
    func but(_ step: String) -> Scenario {
        lastContext = "But"
        addStep(step)
        return self
    }
    
    func and(_ step: String) -> Scenario {
        if (lastContext.isEmpty) {
            fatalError("Trying to add an [and] step without previous context.")
        }
        addStep(step)
        return self
    }
}
