/// Protocol for resolving secrets by their ID.
public protocol SecretResolver {
    /// Resolves a list of secrets by their IDs.
    func resolve(secretids: [String]) async throws -> [Secret]

    /// Resolves a single secret by its ID.
    func resolve(secretid: String) async throws -> Secret
}
