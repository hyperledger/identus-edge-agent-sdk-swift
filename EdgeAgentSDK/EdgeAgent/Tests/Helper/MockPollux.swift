import Domain
import Foundation

struct MockCredential: Credential, StorableCredential, ExportableCredential {
    var storingId: String = ""
    var recoveryId: String = ""
    var credentialData: Data = Data()
    var queryIssuer: String? = nil
    var querySubject: String? = nil
    var queryCredentialCreated: Date? = nil
    var queryCredentialUpdated: Date? = nil
    var queryCredentialSchema: String? = nil
    var queryValidUntil: Date? = nil
    var queryRevoked: Bool? = nil
    var queryAvailableClaims: [String] = []
    var id: String = ""
    var issuer: String = ""
    var subject: String? = nil
    var claims: [Domain.Claim] = []
    var properties: [String : Any] = [:]
    var credentialType: String = ""
    var index: Int? = nil
    var exporting: Data
    var restorationType: String
}

struct MockPollux: Pollux & CredentialImporter {
    func parseCredential(
        type: String,
        credentialPayload: Data,
        options: [Domain.CredentialOperationsOptions]
    ) async throws -> any Domain.Credential {
        return MockCredential(exporting: Data(count: 5), restorationType: "mocked")
    }
    
    func processCredentialRequest(
        type: String,
        offerPayload: Data,
        options: [Domain.CredentialOperationsOptions]
    ) async throws -> String {
        ""
    }
    
    func verifyPresentation(
        type: String,
        presentationPayload: Data,
        options: [Domain.CredentialOperationsOptions]
    ) async throws -> Bool {
        false
    }
    
    func importCredential(
        credentialData: Data,
        restorationType: String,
        options: [CredentialOperationsOptions]
    ) async throws -> Credential {
        return MockCredential(exporting: Data(count: 5), restorationType: "mocked")
    }
    func restoreCredential(restorationIdentifier: String, credentialData: Data) throws -> Domain.Credential {
        return MockCredential(exporting: Data(count: 5), restorationType: "mocked")
    }

    func parseCredential(issuedCredential: Domain.Message, options: [Domain.CredentialOperationsOptions]) async throws -> Domain.Credential {
        return MockCredential(exporting: Data(count: 5), restorationType: "mocked")
    }

    func processCredentialRequest(offerMessage: Domain.Message, options: [Domain.CredentialOperationsOptions]) async throws -> String {
        ""
    }

    func createPresentationRequest(
        type: Domain.CredentialType,
        toDID: Domain.DID,
        name: String,
        version: String,
        claimFilters: [Domain.ClaimFilter]
    ) throws -> Data {
        Data()
    }

    func verifyPresentation(message: Domain.Message, options: [Domain.CredentialOperationsOptions]) async throws -> Bool {
        false
    }
}
