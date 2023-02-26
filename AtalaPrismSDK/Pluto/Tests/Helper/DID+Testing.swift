import Domain

extension DID {
    init(testMethod: String = "test", testMethodId: String = "testableId") {
        self.init(method: testMethod, methodId: testMethodId)
    }

    init(index: Int) {
        self.init(method: "test\(index)", methodId: "testableId\(index)")
    }
}
