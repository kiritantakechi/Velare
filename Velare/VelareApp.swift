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
        WindowGroup("app.view.mainWindow.title", id: "main-window") {
            let coordinatorViewModel = CoordinatorViewModel(coordinator: coordinator)

            CoordinatorView(viewModel: coordinatorViewModel)
        }

        Window("app.view.overlayWindow.title", id: "overlay-window") {
            let overlayViewModel = OverlayViewModel(coordinator: coordinator)

            OverlayView(viewModel: overlayViewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
