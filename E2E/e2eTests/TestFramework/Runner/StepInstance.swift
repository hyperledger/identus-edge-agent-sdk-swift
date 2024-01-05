import Foundation

class StepInstance {
    let id: String
    var context: String = ""
    var step: String = ""
    var error: Error? = nil
    
    init() {
        id = UUID().uuidString
    }
    
    static func == (lhs: StepInstance, rhs: StepInstance) -> Bool {
        return lhs.context == rhs.context && lhs.step == rhs.step
    }
}
