//
//  atala_prism_challenger_appApp.swift
//  atala-prism-challenger-app
//
//  Created by Goncalo Frade IOHK on 31/10/2022.
//

import SwiftUI

@main
struct atala_prism_challenger_appApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModelImpl(), router: ContentRouterImpl())
                .environment(\.colorScheme, .light)
        }
    }
}
