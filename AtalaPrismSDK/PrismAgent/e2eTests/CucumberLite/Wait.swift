import Foundation

class Wait {
    static func until(timeout: Int = 30, callback: () async throws -> Bool) async throws {
        let startTime = Date()
        while try await !callback() {
            if Date().timeIntervalSince(startTime) >= Double(timeout) {
                throw TimeoutError.timeoutReached
            }
            try await Task.sleep(nanoseconds: UInt64(500000000))
        }
    }
}

enum TimeoutError: Error {
    case timeoutReached
}
