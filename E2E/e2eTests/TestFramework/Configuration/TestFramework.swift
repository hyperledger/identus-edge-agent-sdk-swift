import Foundation

protocol TestFrameworkProtocol {
    static var instance: TestFrameworkProtocol? {get set}
    static func getInstance() -> any TestFrameworkProtocol
    
    /// overridable
    static var logLevel: CucumberLogLevel {get set}
    static func createInstance() -> TestFrameworkProtocol
    static func createActors() async throws -> [String: Actor]
    static func setUp() async throws
    static func tearDown() async throws
}

class TestFramework: TestFrameworkProtocol {
    static let logger = ConsoleReporter()
    
    private static var instanceType: TestFrameworkProtocol.Type? = nil
    static var instance: TestFrameworkProtocol? = nil
    static var logLevel: CucumberLogLevel = .DEBUG
    
    static var features: [String] = []
    static var steps: [Steps] = []
    static var actors: [String: Actor] = [:]
    
    static var environment: [String: String] = { readEnvironmentVariables() }()
    
    class func createInstance() -> TestFrameworkProtocol {
        fatalError("Configuration must implement configureInstance method")
    }
    
    class func createActors() async throws -> [String : Actor]  {
        fatalError("Configuration must implement createActors method")
    }
    
    class func setUp() async throws {
        fatalError("Configuration must implement setUp method")
    }
    
    class func tearDown() async throws {
        fatalError("Configuration must implement tearDown method")
    }
    
    static func getInstance() -> TestFrameworkProtocol {
        return instance!
    }
    
    static func setUpConfig() async throws {
        TestFramework.logger.setLevel(.CONFIG)
        TestFramework.logger.enableAutoflush()
        try await setupInstance()
        try await setupSteps()
        try await setupActors()
        TestFramework.logger.disableAutoflush()
    }
    
    static func tearDownConfig() async throws {
        TestFramework.logger.setLevel(.CONFIG)
        TestFramework.logger.enableAutoflush()
        try await tearDownSteps()
        try await tearDownActors()
        try await tearDownInstance()
        TestFramework.logger.reset()
    }
    
    private static func setupActors() async throws {
        actors = try await instanceType!.createActors()
        for actor in actors.values {
            try await actor.initialize()
        }
    }
    
    private static func tearDownActors() async throws {
        for actor in actors.values {
            try await actor.tearDown()
        }
    }
    
    private static func setupSteps() async throws {
        let subclasses = ClassLocator.subclasses(of: Steps.self)
        for subclass in subclasses {
            if (subclass != Steps.self) {
                steps.append(try await (subclass as! Steps.Type).init())
            }
        }
    }
    
    private static func tearDownSteps() async throws {
        for step in steps {
            try await step.tearDown()
        }
    }
    
    private static func setupInstance() async throws {
        if (instance != nil) {
            return
        }
        
        let subclasses = ClassLocator.subclasses(of: TestFramework.self).filter { $0 != TestFramework.self }
        if (subclasses.count == 0) {
            fatalError("No configuration class found. Create a class that extends CucumberConfig class.")
        }
        if (subclasses.count > 1) {
            fatalError("More than 1 configuration class found.")
        }
        instanceType = (subclasses[0] as! TestFrameworkProtocol.Type)
        instance = instanceType!.createInstance()
        try await instanceType!.setUp()
    }
    
    private static func tearDownInstance() async throws {
        try await instanceType!.tearDown()
    }
    
    private static func readEnvironmentVariables() -> [String: String] {
        var environment: [String: String] = [:]
        // load property file
        if let path = Bundle.module.path(forResource: "properties", ofType: "plist", inDirectory: "Resources") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                if let dictionary = try? (PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: String]) {
                    dictionary.forEach {
                        environment[$0.key] = $0.value
                    }
                }
            }
        }
        // overrides if any environment variable is available
        ProcessInfo.processInfo.environment.forEach {
            environment[$0.key] = $0.value
        }
        return environment
    }
    
    /// Default parsers
    @ParameterParser
    var actorParser = { (actor: String) in
        return actors[actor]!
    }
    
    @ParameterParser
    var stringParser = { (string: String) in
        return string
    }
    
    @ParameterParser
    var intParser = { (int: String) in
        return Int(int)!
    }
    
    enum Failure: Error {
        case stepParameterDoesNotMatch(step: String, expected: String, actual: String)
        case stepNotFound(step: String)
        case parameterTypeNotFound
        case executionFailure(error: Error)
    }
}
