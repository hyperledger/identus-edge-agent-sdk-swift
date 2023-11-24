import Foundation
import XCTest


class Feature: XCTestCase {
    private var steps: [Steps] = []

    override init() {
        super.init()
        _ = featureTitle()
    }
    
    func featureTitle() -> String {
        fatalError("Set feature title")
    }
    
    func featureDescription() -> String {
        return ""
    }
    
    override func setUp() async throws {
        steps = []
        let subclasses = Runtime.subclasses(of: Steps.self)
        for subclass in subclasses {
            if (subclass != Steps.self) {
                steps.append(try await (subclass as! Steps.Type).init())
            }
        }
    }
    
    override func tearDown() async throws {
        for step in steps {
            try await step.teardown()
        }
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
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
                if class_conformsToProtocol(aClass, `protocol`) { print(String(describing: aClass)); return true }
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
