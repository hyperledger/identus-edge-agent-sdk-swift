import Foundation

class StepOutcome {
    let step: StepInstance
    var error: Error?
    
    init(_ step: StepInstance, _ error: Error? = nil) {
        self.step = step
        self.error = error
    }
}
