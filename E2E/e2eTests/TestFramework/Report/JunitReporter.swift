import Foundation

class JunitReporter: Reporter {
    let root = XMLElement(name: "testsuites")
    let xml: XMLDocument
    
    var currentFeature = XMLElement(name: "testsuite")
    var currentScenario = XMLElement(name: "testcase")
    
    let testSuitesStart = Date()
    var featureStart = Date()
    var scenarioStart = Date()
    
    var totalTests = 0
    var totalFailures = 0
    var featureTests = 0
    var featureFailures = 0

    init() {
        xml = XMLDocument(rootElement: root)
        xml.version = "1.0"
        xml.characterEncoding = "UTF-8"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"

        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        
        let id = XMLNode.attribute(withName: "id", stringValue: formattedDate) as! XMLNode
        let name = XMLNode.attribute(withName: "name", stringValue: "swift-e2e-results - \(Date().formatted())") as! XMLNode
        
        root.addAttribute(id)
        root.addAttribute(name)
    }
    
    func beforeFeature(_ feature: Feature) async throws {
        featureStart = Date()
        currentFeature = XMLElement(name: "testsuite")
        featureTests = 0
        featureFailures = 0
        
        let id = XMLNode.attribute(withName: "id", stringValue: feature.id) as! XMLNode
        let name = XMLNode.attribute(withName: "name", stringValue: feature.title()) as! XMLNode
        
        currentFeature.addAttribute(id)
        currentFeature.addAttribute(name)
        
        root.addChild(currentFeature)
    }
    
    func beforeScenario(_ scenario: Scenario) async throws {
        scenarioStart = Date()
        currentScenario = XMLElement(name: "testcase")
        
        let id = XMLNode.attribute(withName: "id", stringValue: scenario.id) as! XMLNode
        let name = XMLNode.attribute(withName: "name", stringValue: scenario.title) as! XMLNode
        
        currentScenario.addAttribute(id)
        currentScenario.addAttribute(name)
        
        currentFeature.addChild(currentScenario)
    }
    
    func beforeStep(_ step: StepInstance) async throws {
    }
    
    func action(_ action: String) async throws {
    }
    
    func afterStep(_ stepOutcome: StepOutcome) async throws {
    }
    
    func afterScenario(_ scenarioOutcome: ScenarioOutcome) async throws {
        featureTests += 1
        let delta = String(format: "%.4f seconds", Date().timeIntervalSince(scenarioStart))
        let time = XMLNode.attribute(withName: "time", stringValue: delta) as! XMLNode
        currentScenario.addAttribute(time)
        
        if (scenarioOutcome.error != nil) {
            let failure = XMLElement(name: "failure")
            featureFailures += 1
            let message = XMLNode.attribute(withName: "message", stringValue: String(describing: scenarioOutcome.error!)) as! XMLNode
            let type = XMLNode.attribute(withName: "type", stringValue: "ERROR") as! XMLNode
            failure.addAttribute(message)
            failure.addAttribute(type)
            
            currentScenario.addChild(failure)
        }
    }
    
    func afterFeature(_ featureOutcome: FeatureOutcome) async throws {
        let delta = String(format: "%.4f seconds", Date().timeIntervalSince(featureStart))
        let time = XMLNode.attribute(withName: "time", stringValue: delta) as! XMLNode
        let tests = XMLNode.attribute(withName: "tests", stringValue: featureTests.value) as! XMLNode
        let failures = XMLNode.attribute(withName: "failures", stringValue: featureFailures.value) as! XMLNode
        currentFeature.addAttribute(time)
        currentFeature.addAttribute(tests)
        currentFeature.addAttribute(failures)
        
        totalTests += featureTests
        totalFailures += featureFailures
    }
    
    func afterFeatures(_ featuresOutcome: [FeatureOutcome]) async throws {
        let delta = String(format: "%.4f seconds", Date().timeIntervalSince(testSuitesStart))
        let time = XMLNode.attribute(withName: "time", stringValue: delta) as! XMLNode
        let tests = XMLNode.attribute(withName: "tests", stringValue: totalTests.value) as! XMLNode
        let failures = XMLNode.attribute(withName: "failures", stringValue: totalFailures.value) as! XMLNode
        
        root.addAttribute(time)
        root.addAttribute(tests)
        root.addAttribute(failures)
        
        let outputPath = TestConfiguration.shared().targetDirectory().appendingPathComponent("junit.xml")
        let prettyPrintOptions: XMLNode.Options = [.nodePrettyPrint]
        let prettyPrintedData = xml.xmlData(options: prettyPrintOptions)
        let summary = String(data: prettyPrintedData, encoding: .utf8)
        try summary!.write(to: outputPath, atomically: true, encoding: .utf8)
    }
}
