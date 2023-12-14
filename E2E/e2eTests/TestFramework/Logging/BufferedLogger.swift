import Foundation

protocol BufferedLoggerProtocol {
    func enableAutoflush()
    func disableAutoflush()
    func reset()
    func trace(_ items: Any...)
    func debug(_ items: Any...)
    func info(_ items: Any...)
    func warning(_ items: Any...)
    func error(_ items: Any...)
    func logLine()
}

class BufferedLogger: BufferedLoggerProtocol {
    static let pass = "(✔)"
    static let fail = "(✘)"
    
    private var buffer: [(UInt64, CucumberLogLevel, String)] = []
    private var autoFlush = false
    private var showTimestamp = true
    private let indentation: Int
    
    init(_ level: Level) {
        switch(level) {
        case .CONFIG:
            indentation = 0
        case .FEATURE:
            indentation = 0
        case .SCENARIO:
            indentation = 4
        case .STEP:
            indentation = 8
        case .TASK:
            indentation = 12
        }
    }
    
    enum Level {
        case CONFIG
        case FEATURE
        case SCENARIO
        case STEP
        case TASK
    }
    
    func enableAutoflush() {
        autoFlush = true
    }
    
    func disableAutoflush() {
        autoFlush = false
    }
    
    func reset() {
        autoFlush = false
        buffer = []
    }
    
    func trace(_ items: Any...) {
        log(items, level: .TRACE)
    }
    
    func debug(_ items: Any...) {
        log(items, level: .DEBUG)
    }
    
    func info(_ items: Any...) {
        log(items, level: .INFO)
    }
    
    func warning(_ items: Any...) {
        log(items, level: .WARNING)
    }
    
    func error(_ items: Any...) {
        log(items, level: .ERROR)
    }
    
    func logLine() {
        info("--------------------------------------------------")
    }
    
    func appendResultToLast(hasFailed: Bool) {
        if (buffer.count == 0) {
            return
        }
        
        for i in 0..<buffer.count - 1 {
            buffer[i].2 = BufferedLogger.pass + " " + buffer[i].2
        }
        let lastEntryIndex = buffer.count - 1
        if (hasFailed) {
            buffer[lastEntryIndex].2 = BufferedLogger.fail + " " + buffer[lastEntryIndex].2
        } else {
            buffer[lastEntryIndex].2 = BufferedLogger.pass + " " + buffer[lastEntryIndex].2
        }
    }
    
    func formatted() -> [(UInt64, String)] {
        var formattedBuffer: [(UInt64, String)] = []
        for i in 0..<buffer.count {
            if (buffer[i].1.rawValue >= TestFramework.logLevel.rawValue) {
                formattedBuffer.append((buffer[i].0, formatLine(buffer[i])))
            }
        }
        return formattedBuffer
    }
    
    private func formatLine(_ logLine: (UInt64, CucumberLogLevel, String)) -> String {
        return (showTimestamp ? "[" + convertNanosecondsToReadableTime(logLine.0) + "] " : "")
                + (indentation > 0 ? String(repeating: " ", count: indentation) + " " : "")
                + (logLine.2)
    }
    
    func flush() {
        buffer.forEach { logLine in
            if (logLine.1.rawValue >= TestFramework.logLevel.rawValue) {
                print(formatLine(logLine))
            }
        }
        buffer = []
    }
    
    private func log(
        _ items: [Any],
        level: CucumberLogLevel,
        separator: String = " ",
        terminator: String = "\n"
    ) {
        let output = items.map { String(describing: $0) }.joined(separator: separator)
        let currentTime = DispatchTime.now().uptimeNanoseconds
        buffer.append((currentTime, level, output))
        if (autoFlush) {
            flush()
        }
    }
    
    private func convertNanosecondsToReadableTime(_ nanoseconds: UInt64) -> String {
        let seconds = Double(nanoseconds) / 1_000_000_000.0
        let date = Date(timeIntervalSinceNow: seconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter.string(from: date)
    }
}
