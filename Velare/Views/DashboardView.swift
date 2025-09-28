//
//  DashboardView.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

struct DashboardView: View {
    @Bindable var coordinator: AppCoordinator
    @State private var viewModel: DashboardViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.viewModel = coordinator.makeDashboardViewModel()
    }

    var body: some View {
        GlassEffectContainer {
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)
            }
            .padding()
        }
    }
}
