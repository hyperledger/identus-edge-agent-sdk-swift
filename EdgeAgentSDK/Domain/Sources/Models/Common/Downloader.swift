import Foundation

/// `Downloader` is a protocol that defines functionality for downloading data from a given endpoint.
public protocol Downloader {
    /// Downloads data from the specified endpoint URL or DID.
    ///
    /// - Parameter urlOrDID: The URL or decentralized identifier (DID) from which the data should be downloaded.
    /// - Returns: The downloaded data as `Data`.
    /// - Throws: An error if the download fails or the endpoint is unreachable.
    func downloadFromEndpoint(urlOrDID: String) async throws -> Data
}
