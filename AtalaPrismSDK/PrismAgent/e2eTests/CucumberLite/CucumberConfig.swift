import Foundation

protocol CucumberConfigProtocol {
    static var instance: CucumberConfigProtocol? {get set}
    static func getInstance() -> any CucumberConfigProtocol
    
    /// overridable
    static func createInstance() -> CucumberConfigProtocol
    static func createActors() async throws -> [String: Actor]
    static func setUp() async throws
    static func tearDown() async throws
    func logLevel() -> CucumberLogLevel
}

class CucumberConfig: CucumberConfigProtocol {
    private static var instanceType: CucumberConfigProtocol.Type? = nil
    static var instance: CucumberConfigProtocol? = nil
    
    static var features: [String] = []
    static var steps: [Steps] = []
    static var actors: [String: Actor] = [:]
    
    static var environment: [String: String] = { getEnvironment() }()
    
    class func createInstance() -> CucumberConfigProtocol {
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
    
    func logLevel() -> CucumberLogLevel {
        return .DEBUG
    }
    
    static func getInstance() -> CucumberConfigProtocol {
        return instance!
    }
   
    static func setUpConfig() async throws {
        try await setupInstance()
        try await setupSteps()
        try await setupActors()
    }
    
    static func tearDownConfig() async throws {
        try await tearDownSteps()
        try await tearDownActors()
        try await tearDownInstance()
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
        let subclasses = Runtime.subclasses(of: Steps.self)
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
        
        let subclasses = Runtime.subclasses(of: CucumberConfig.self).filter { $0 != CucumberConfig.self }
        if (subclasses.count == 0) {
            fatalError("No configuration class found. Create a class that extends CucumberConfig class.")
        }
        if (subclasses.count > 1) {
            fatalError("More than 1 configuration class found.")
        }
        instanceType = (subclasses[0] as! CucumberConfigProtocol.Type)
        instance = instanceType!.createInstance()
        try await instanceType!.setUp()
    }
    
    private static func tearDownInstance() async throws {
        try await instanceType!.tearDown()
    }
    
    private static func getEnvironment() -> [String: String] {
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
}

enum CucumberError: Error {
    case stepParameterDoesNotMatch(step: String, expected: String, actual: String)
    case stepNotFound(step: String)
}

enum CucumberLogLevel: Int {
    case TRACE = 0
    case DEBUG = 1
    case INFO = 2
    case WARNING = 3
    case ERROR = 4
}

private class Runtime {
    
    public static func allClasses() -> [AnyClass] {
        let numberOfClasses = Int(objc_getClassList(nil, 0))
        if numberOfClasses > 0 {
            let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
            let autoreleasingClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
            let count = objc_getClassList(autoreleasingClasses, Int32(numberOfClasses))
            assert(numberOfClasses == count)
            defer { classesPtr.deallocate() }
            let classes = (0 ..< numberOfClasses).map { classesPtr[$0] }
            return classes
        }
        return []
    }
    
    public static func subclasses(of `class`: AnyClass) -> [AnyClass] {
        return self.allClasses().filter {
            var ancestor: AnyClass? = $0
            while let type = ancestor {
                if ObjectIdentifier(type) == ObjectIdentifier(`class`) { return true }
                ancestor = class_getSuperclass(type)
            }
            return false
        }
    }
    
    public static func classes(conformToProtocol `protocol`: Protocol) -> [AnyClass] {
        let classes = self.allClasses().filter { aClass in
            var subject: AnyClass? = aClass
            while let aClass = subject {
                if class_conformsToProtocol(aClass, `protocol`) { return true }
                subject = class_getSuperclass(aClass)
            }
            return false
        }
        return classes
    }
    
    public static func classes<T>(conformTo: T.Type) -> [AnyClass] {
        return self.allClasses().filter { $0 is T }
    }
}
