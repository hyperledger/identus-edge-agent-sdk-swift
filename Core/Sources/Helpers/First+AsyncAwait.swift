import Combine

extension Publishers {
    struct MissingOutputError: Error {}
}

public extension Publishers.First where Failure == Error {
    func await() async throws -> Output {
        for try await output in values {
            return output
        }
        throw Publishers.MissingOutputError()
    }
}
