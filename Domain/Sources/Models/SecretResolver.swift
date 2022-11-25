public protocol SecretResolver {
    func resolve(secretids: [String]) async throws -> Secret
}
