import Domain
import Foundation

struct PrismDIDMethodId: CustomStringConvertible {
    private let value: String
    var description: String { value }
    var sections: [String] { value.split(separator: ":").map { String($0) } }

    init(sections: [String]) throws {
        let sectionRegex = "^[A-Za-z0-9_-]+$"
        guard
            sections.allSatisfy({
                let range = $0.range(of: sectionRegex, options: .regularExpression)
                return range != nil
            })
        else { throw CastorError.methodIdIsDoesNotSatisfyRegex }
        value = sections.joined(separator: ":")
    }

    init(string: String) throws {
        let methodSpecifiIdRegex = "^([A-Za-z0-9_-]*:)*[A-Za-z0-9_-]+$"
        guard
            string.range(of: methodSpecifiIdRegex, options: .regularExpression) != nil
        else { throw CastorError.methodIdIsDoesNotSatisfyRegex }
        value = string
    }
}
