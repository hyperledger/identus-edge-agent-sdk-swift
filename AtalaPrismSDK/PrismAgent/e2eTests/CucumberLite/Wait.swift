import Foundation

class Wait {
    static func until(callback: () async throws -> Bool, timeout: Int = 30) async throws {
        let startTime = Date()
        while try await !callback() {
            if Date().timeIntervalSince(startTime) >= Double(timeout) {
                throw TimeoutError.timeoutReached
            }
            try await Task.sleep(nanoseconds: UInt64(1000000))
        }
    }
}

enum TimeoutError: Error {
    case timeoutReached
}
