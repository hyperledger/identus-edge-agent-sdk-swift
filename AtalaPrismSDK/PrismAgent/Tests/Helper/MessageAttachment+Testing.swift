@testable import Domain
import Foundation

extension AttachmentDescriptor: Equatable {
    public static func == (lhs: Domain.AttachmentDescriptor, rhs: Domain.AttachmentDescriptor) -> Bool {
        lhs.id == rhs.id && lhs.mediaType == rhs.mediaType
    }
}
