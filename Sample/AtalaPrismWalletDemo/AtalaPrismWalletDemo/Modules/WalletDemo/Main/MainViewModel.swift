import Combine
import Domain
import Foundation
import PrismAgent

final class MainViewModelImpl: MainViewModel {
    @Published var didString: String = "did:peer:2.Ez6LSo3ResPPWyCGRohY1xS5qYWUVkPMusLknMVT9x8FNAAnk.Vz6Mkhs7twmSqp2DvgVXDTWVD8S8x9Q7eLg6J8EaXoyHhnWmh.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwOi8vcm9vdHNpZC1tZWRpYXRvcjo4MDAwIiwiYSI6WyJkaWRjb21tL3YyIl19"
    @Published var oobString: String = "https://mediator.rootsid.cloud?_oob=eyJ0eXBlIjoiaHR0cHM6Ly9kaWRjb21tLm9yZy9vdXQtb2YtYmFuZC8yLjAvaW52aXRhdGlvbiIsImlkIjoiNzk0Mjc4MzctY2MwNi00ODUzLWJiMzktNjg2ZWFjM2U2YjlhIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNtczU1NVloRnRobjFXVjhjaURCcFptODZoSzl0cDgzV29qSlVteFBHazFoWi5WejZNa21kQmpNeUI0VFM1VWJiUXc1NHN6bTh5dk1NZjFmdEdWMnNRVllBeGFlV2hFLlNleUpwWkNJNkltNWxkeTFwWkNJc0luUWlPaUprYlNJc0luTWlPaUpvZEhSd2N6b3ZMMjFsWkdsaGRHOXlMbkp2YjNSemFXUXVZMnh2ZFdRaUxDSmhJanBiSW1ScFpHTnZiVzB2ZGpJaVhYMCIsImJvZHkiOnsiZ29hbF9jb2RlIjoicmVxdWVzdC1tZWRpYXRlIiwiZ29hbCI6IlJlcXVlc3RNZWRpYXRlIiwibGFiZWwiOiJNZWRpYXRvciIsImFjY2VwdCI6WyJkaWRjb21tL3YyIl19fQ"
    @Published var toast: FancyToast?
    @Published var routeToDashboard = false
    private let router: MainViewRouterImpl
    private var cancellables = [AnyCancellable]()

    init(router: MainViewRouterImpl) {
        self.router = router
    }

    func startWithMediatorDID() {
        do {
            let did = try DID(string: didString)
            self.router.didOnUse = did
            self.routeToDashboard = true
        } catch {
            self.didString = ""
            self.toast = .init(type: .error, title: "Invalid DID", message: didString)
        }
    }

    func startWithMediatorOOB() {
        do {
            let invitation = try PrismAgent(
                mediatorDID: DID(method: "peer", methodId: "123")
            ).parseOOBInvitation(url: oobString)
            self.router.didOnUse = try DID(string: invitation.from)
            self.routeToDashboard = true
        } catch {
            self.didString = ""
            self.toast = .init(type: .error, title: "Invalid OOB", message: oobString)
        }
    }
}
