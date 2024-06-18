import Domain
import EdgeAgent
import Foundation

final class BackupViewModelImpl: BackupViewModel {
    @Published var newJWE: String? = nil

    private let agent: EdgeAgent
    
    init(agent: EdgeAgent) {
        self.agent = agent
    }

    func createNewJWE() async throws {
        let jwe = try await agent.backupWallet()

        await MainActor.run {
            self.newJWE = jwe
        }
    }

    func backupWith(_ jwe: String) async throws {
        do {
            try await agent.recoverWallet(encrypted: jwe)
        } catch {
            print(error)
            print()
            throw error
        }
    }
}
