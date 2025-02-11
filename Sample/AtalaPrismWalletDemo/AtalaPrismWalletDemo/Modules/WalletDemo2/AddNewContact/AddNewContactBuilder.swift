import Domain
import EdgeAgent
import SwiftUI

struct AddNewContactComponent: ComponentContainer {
    let container: DIContainer
    let token: String?
}

struct AddNewContactBuilder: Builder {
    func build(component: AddNewContactComponent) -> some View {
        let viewModel = getViewModel(component: component) {
            AddNewContactViewModelImpl(
                token: component.token ?? "",
                agent: component.container.resolve(type: DIDCommAgent.self)!, 
                oidcAgent: component.container.resolve(type: OIDCAgent.self)!,
                pluto: component.container.resolve(type: Pluto.self)!
            )
        }
        return AddNewContactView<AddNewContactViewModelImpl>(viewModel: viewModel)
            .onDisappear {
                component.container.unregister(type: AddNewContactViewModelImpl.self)
            }
    }
}
