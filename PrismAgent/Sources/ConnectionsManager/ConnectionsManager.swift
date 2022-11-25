import Domain
import Foundation

class ConnectionsManager {
    private let mercury: Mercury
    private let pluto: Pluto
    private var connections: [DIDCommConnection]

    init(
        mercury: Mercury,
        pluto: Pluto,
        connections: [Connection]
    ) {
        self.mercury = mercury
        self.pluto = pluto
        self.connections = connections
    }

    func awaitForMessageResponse(fromDID: DID, id: String) async throws -> Message? {
        guard
            let connection = connections.first(where: { $0.otherDID == fromDID })
        else { throw PrismAgentError.noConnectionOpenError }
        return try await connection.awaitMessageResponse(id: id)
    }

    func addConnection(_ connection: DIDCommConnection) {
        guard
            !connections.contains(where: {
                $0.holderDID == connection.holderDID && $0.otherDID == connection.otherDID
            })
        else { return }
        connections.append(connection)
    }

    func removeConnection(_ connection: DIDCommConnection) -> DIDCommConnection? {
        connections.firstIndex(where: {
            $0.holderDID == connection.holderDID && $0.otherDID == connection.otherDID
        }).map {
            connections.remove(at: $0)
        }
    }
}
