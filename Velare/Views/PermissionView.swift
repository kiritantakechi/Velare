//
//  PermissionView.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

struct PermissionView: View {
    @Bindable var coordinator: AppCoordinator
    @State private var viewModel: PermissionViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.viewModel = coordinator.makePermissionViewModel()
    }

    var body: some View {
        GlassEffectContainer {
            VStack {
                Text("Check Permissions")
                    .font(.largeTitle)
                Button("Grant Permissions") {
                    coordinator.permissionsGranted()
                }
            }
            .padding()
        }
    }
}
