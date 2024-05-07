import Domain
import Foundation

struct MockDownloader: Downloader {
    let returnData: Data
    func downloadFromEndpoint(urlOrDID: String) async throws -> Data {
        return returnData
    }
}
