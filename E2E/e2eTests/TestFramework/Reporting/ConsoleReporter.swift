import Foundation

/// Logger
class ConsoleReporter: BufferedLoggerProtocol {
    private let config = BufferedLogger(.CONFIG)
    private let feature = BufferedLogger(.FEATURE)
    private let scenario = BufferedLogger(.SCENARIO)
    private let step = BufferedLogger(.STEP)
    private let task = BufferedLogger(.TASK)
    
    private var actual: BufferedLogger
    
    init() {
        self.actual = config
    }
    
    func enableAutoflush() {
        actual.enableAutoflush()
    }
    
    func disableAutoflush() {
        actual.disableAutoflush()
    }
    
    func reset() {
        actual.reset()
    }
    
    func trace(_ items: Any...) {
        actual.trace(items)
    }
    
    func debug(_ items: Any...) {
        actual.debug(items)
    }
    
    func info(_ items: Any...) {
        actual.info(items)
    }
    
    func warning(_ items: Any...) {
        actual.warning(items)
    }
    
    func error(_ items: Any...) {
        actual.error(items)
    }
    
    func logLine() {
        actual.logLine()
    }
    
    func getLogger(_ level: BufferedLogger.Level) -> BufferedLogger {
        switch (level) {
        case .CONFIG:
            return config
        case .FEATURE:
            return feature
        case .SCENARIO:
            return scenario
        case .STEP:
            return step
        case .TASK:
            return task
        }
    }
    
    func setLevel(_ level: BufferedLogger.Level) {
        actual = getLogger(level)
    }
    
    func printAll() {
        var allLogs: [(UInt64, String)] = config.formatted() + feature.formatted() + scenario.formatted() + step.formatted() + task.formatted()
        allLogs.sort(by: { $0.0 < $1.0 })
        allLogs.forEach {logLine in
            print(logLine.1)
        }
    }
    
    func clearAll() {
        config.reset()
        feature.reset()
        scenario.reset()
        step.reset()
        task.reset()
    }
    
    static func writeToGithubSummary(_ command: String) {
        //        if (ProcessInfo.processInfo.environment.keys.contains("CI")) {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            print("Command output:\n\(output)")
        }
    }
}
