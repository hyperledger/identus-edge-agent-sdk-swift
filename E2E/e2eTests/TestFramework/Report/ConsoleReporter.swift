import Foundation

class ConsoleReporter: Reporter {
    private static let pass = "(✔)"
    private static let fail = "(✘)"
    
    func beforeFeature(_ feature: Feature) {
        log()
        logLine()
        log("Feature:", feature.title())
        if (!feature.description().isEmpty) {
            log("Description:", feature.description())
        }
        logLine()
    }
    
    func beforeScenario(_ scenario: Scenario) {
        logLine()
        log("Scenario:", scenario.title)
        logLine()
    }
    
    func beforeStep(_ step: StepInstance) {
        
    }
    
    func action(_ action: String) {
        
    }
    
    func afterStep(_ stepOutcome: StepOutcome) {
        
    }
    
    func afterScenario(_ scenarioOutcome: ScenarioOutcome) {
        logLine()
        log("Result:", scenarioOutcome.error == nil ? "PASS" : "FAILED")
        logLine()
    }
    
    func afterFeature(_ featureOutcome: FeatureOutcome) {
        log("Finished")
    }
    
    func afterFeatures(_ featuresOutcome: [FeatureOutcome]) {
        
    }

    private var buffer: [(UInt64, String)] = []
    private var showTimestamp = true
    private var indentation: Int = 0
    
    func increaseIndentation() {
        indentation += 4
    }
    
    func decreaseIndentation() {
        indentation -= 4
        if (indentation < 0) {
            indentation = 0
        }
    }

    private func logLine() {
        log("--------------------------------------------------")
    }

    func formatted() -> [(UInt64, String)] {
        var formattedBuffer: [(UInt64, String)] = []
        for i in 0..<buffer.count {
            formattedBuffer.append((buffer[i].0, formatLine(buffer[i])))
        }
        return formattedBuffer
    }
    
    private func formatLine(_ logLine: (UInt64, String)) -> String {
        return (showTimestamp ? "[" + convertNanosecondsToReadableTime(logLine.0) + "] " : "")
                + (indentation > 0 ? String(repeating: " ", count: indentation) + " " : "")
                + (logLine.1)
    }
    
    func flush() {
        buffer.forEach { logLine in
            print(formatLine(logLine))
        }
        buffer = []
    }
    
    private func printFooter() {
        //        let logger = TestFramework.logger.getLogger(.FEATURE)
        //        logger.info("\n")
        //        logger.logLine()
        //        logger.info("Scenarios summary")
        //        logger.logLine()
        //        var isFailed = false
        //        scenarios.forEach { scenario in
        //            if (scenario.1 != nil) {
        //                isFailed = true
        //                logger.error(BufferedLogger.fail, scenario.0.name)
        //            } else {
        //                logger.info(BufferedLogger.pass, scenario.0.name)
        //            }
        //        }
        //        logger.logLine()
        //        logger.info(featureInitialization.last!)
        //        logger.info((isFailed ? "FAILED" : "PASS"))
        //        logger.logLine()
        //
        //        logger.flush()
    }
    
    private func log(
        _ items: Any...,
        separator: String = " ",
        terminator: String = "\n"
    ) {
        let output = items.map { String(describing: $0) }.joined(separator: separator)
        let currentTime = DispatchTime.now().uptimeNanoseconds
        buffer.append((currentTime, output))
    }
    
    private func convertNanosecondsToReadableTime(_ nanoseconds: UInt64) -> String {
        let seconds = Double(nanoseconds) / 1_000_000_000.0
        let date = Date(timeIntervalSinceNow: seconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter.string(from: date)
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
