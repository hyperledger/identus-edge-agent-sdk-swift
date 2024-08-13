import EdgeAgent
import SwiftUI

struct BackupComponent: ComponentContainer {
    let container: DIContainer
}

struct BackupBuilder: Builder {
    func build(component: BackupComponent) -> some View {
        let viewModel = getViewModel(component: component) {
            BackupViewModelImpl(agent: component.container.resolve(type: DIDCommAgent.self)!)
        }
        return BackupView(viewModel: viewModel)
    }
}
