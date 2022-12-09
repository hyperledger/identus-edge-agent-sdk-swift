public protocol SecretResolver {
    func resolve(secretids: [String]) async throws -> Secret
    func resolve(secretid: [String]) async throws -> Secret
}
