//
//  VelareApp.swift
//  Velare
//
//  Created by Kiritan on 2025/09/27.
//

import SwiftUI

@main
struct VelareApp: App {
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            let coordinatorViewModel = CoordinatorViewModel(coordinator: coordinator)

            CoordinatorView(viewModel: coordinatorViewModel)
        }
    }
}
