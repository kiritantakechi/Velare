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

        Window("Velare Overlay", id: "overlay-window") {
            let overlayViewModel = OverlayViewModel(coordinator: coordinator)

            OverlayView(viewModel: overlayViewModel)
        }
        .windowStyle(.hiddenTitleBar) // 隐藏标题栏
        .windowResizability(.contentSize) // 窗口大小由内容决定
        .defaultPosition(.center)
    }
}
