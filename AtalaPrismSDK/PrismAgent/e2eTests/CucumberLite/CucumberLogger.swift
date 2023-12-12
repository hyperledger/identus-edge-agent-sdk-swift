import Foundation

class CucumberLogger {
    private static func log(_ items: [Any], level: CucumberLogLevel, separator: String = " ", terminator: String = "\n") {
        if (CucumberConfig.getInstance().logLevel().rawValue >= level.rawValue) {
            return
        }
        
        let output = items.map { String(describing: $0) }.joined(separator: separator)
        print(output, terminator: terminator)
    }
    
    static func trace(_ items: Any...) {
        log(items, level: .TRACE)
    }
    
    static func debug(_ items: Any...) {
        log(items, level: .DEBUG)
    }
    
    static func info(_ items: Any...) {
        log(items, level: .INFO)
    }
    
    static func warning(_ items: Any...) {
        log(items, level: .WARNING)
    }
    
    static func error(_ items: Any...) {
        log(items, level: .ERROR)
    }
    
    static func logLine() {
        info("--------------------------------------------------")
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
//    }
}

