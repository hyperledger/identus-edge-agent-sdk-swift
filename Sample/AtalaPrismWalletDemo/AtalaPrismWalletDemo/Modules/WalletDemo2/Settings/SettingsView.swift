import SwiftUI

protocol SettingsViewModel: ObservableObject {
    var menu: [SettingsViewState.Menu] { get }
}

protocol SettingsViewRouter {
    associatedtype MediatorV: View
    associatedtype DIDsV: View
    associatedtype BackupV: View

    func routeToMediator() -> MediatorV
    func routeToDIDs() -> DIDsV
    func routeToBackup() -> BackupV
}

class SettingsViewModelImpl: SettingsViewModel {
    @Published var menu = [
        SettingsViewState.Menu.mediator,
        SettingsViewState.Menu.dids,
        SettingsViewState.Menu.backup
    ]
}

struct SettingsView<ViewModel: SettingsViewModel, Router: SettingsViewRouter>: View {

    @StateObject var viewModel: ViewModel
    let router: Router

    var body: some View {
        NavigationStack {
            List(viewModel.menu) { menu in
                NavigationLink(value: menu) {
                    Text(menu.rawValue)
                        .lineLimit(1)
                        .font(.headline)
                        .truncationMode(.middle)
                }
            }
            .navigationDestination(for: SettingsViewState.Menu.self) { menu in
                switch menu {
                case .dids:
                    router.routeToDIDs()
                case .mediator:
                    router.routeToMediator()
                case .backup:
                    router.routeToBackup()
                }
            }
        }
    }
}
