import Foundation

public protocol Downloader {
    func downloadFromEndpoint(urlOrDID: String) async throws -> Data
}
