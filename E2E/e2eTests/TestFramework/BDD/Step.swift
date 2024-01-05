
import Foundation

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
