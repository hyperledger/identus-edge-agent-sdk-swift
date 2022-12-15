import Combine
import Foundation
import PrismAgent

final class ProofOfRequestViewModelImpl: ProofOfRequestViewModel {
    @Published var contact: ProofOfRequestState.Contact = .init(text: "")
    @Published var flowStep: ProofOfRequestState.FlowStep = .loading
    @Published var credential = [ProofOfRequestState.Credential]()
    @Published var checks = [Bool]()
    @Published var loading = false
    @Published var dismiss = false

    private let proofOfRequest: RequestPresentation
    private let agent: PrismAgent
    private var cancellables = Set<AnyCancellable>()

    init(
        proofOfRequest: RequestPresentation,
        agent: PrismAgent
    ) {
        self.proofOfRequest = proofOfRequest
        self.agent = agent
    }

    func viewDidAppear() {
        bind()
    }

    func sendPresentation() {
        guard !loading else { return }
        loading = true
    }

    func share() {

    }

    func confirmDismiss() {
//        proofOfRequestRepository
//            .processedProofOfRequest(proofOfRequest)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                self?.dismiss = true
//            } receiveValue: {}
//            .store(in: &cancellables)
    }

    private func bind() {
//        let proofOfRequest = proofOfRequest
//
//        contactsRepository
//            .getAll()
//            .map { $0.first { $0.token == proofOfRequest.connectionToken } }
//            .first()
//            .replaceError(with: nil)
//            .dropNil()
//            .map { [weak self] in
//                self?.contactDomain = $0
//                return ProofOfRequestState.Contact(
//                    icon: $0.logo.map { .data($0) } ?? .credential,
//                    text: $0.name,
//                    credentialsRequested: mapTypeIDs(proofOfRequest.typeIds)
//                )
//            }
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$contact)
//
//        credentialsRepository
//            .getAll()
//            .replaceError(with: [])
//            .map { $0.filter { proofOfRequest.typeIds.contains($0.type) } }
//            .first()
//            .map {
//                $0.map {
//                    ProofOfRequestState.Credential(
//                        id: $0.id,
//                        text: $0.credentialName
//                    )
//                }
//            }
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] credentials in
//                self?.credential = credentials
//                self?.checks = credentials.map { _ in false }
//                self?.loading = false
//                self?.flowStep = .shareCredentials
//            }
//            .store(in: &cancellables)
    }
}

private func mapTypeIDs(
    _ ids: [String]
) -> [ProofOfRequestState.RequestedCredentials] {
    ids.map { mapTypeID($0) }
}

private func mapTypeID(
    _ id: String
) -> ProofOfRequestState.RequestedCredentials {
    switch id {
    case "ID Government":
        return .idCredential
    case "University Degree":
        return .universityDegree
    case "Proof of employment":
        return .proofOfEmployment
    case "Insurance Credential":
        return .insurance
    default:
        return .custom(id)
    }
}
