import Domain
import EdgeAgent
import Foundation

final class BackupViewModelImpl: BackupViewModel {
    @Published var newJWE: String? = nil

    private let agent: DIDCommAgent
    
    init(agent: DIDCommAgent) {
        self.agent = agent
    }

    func createNewJWE() async throws {
        let jwe = try await agent.edgeAgent.backupWallet()

        await MainActor.run {
            self.newJWE = jwe
        }
    }

    func backupWith(_ jwe: String) async throws {
        do {
            try await agent.edgeAgent.recoverWallet(encrypted: jwe)
        } catch {
            print(error)
            print()
            throw error
        }
    }
}
