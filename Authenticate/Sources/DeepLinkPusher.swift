import Foundation

public protocol DeepLinkPusher {
    func openDeepLink(url: URL) async throws -> Bool
}
