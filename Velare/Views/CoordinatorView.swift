//
//  CoordinatorView.swift
//  Velare
//
//  Created by Kiritan on 2025/09/27.
//

import Combine
import SwiftUI

struct CoordinatorView: View {
    @Bindable var coordinator: AppCoordinator
    @State private var viewModel: CoordinatorViewModel
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.viewModel = coordinator.makeCoordinatorViewModel()
    }

    var body: some View {
        GlassEffectContainer {
            NavigationSplitView {
                List(AppRoute.allCases, selection: $coordinator.selectedRoute) { route in
                    NavigationLink(value: route) {
                        Label(route.localizedName, systemImage: route.iconName)
                    }
                }
                .disabled(coordinator.currentStatus == .loading)
                .navigationTitle("Velare")
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            } detail: {
                Group {
                    if let route = coordinator.selectedRoute {
                        switch route {
                        case .dashboard:
                            DashboardView(coordinator: coordinator)
                        case .capture:
                            CaptureView(coordinator: coordinator)
                        case .setting:
                            SettingView(coordinator: coordinator)
                        case .permission:
                            PermissionView(coordinator: coordinator)
                        }
                    } else {
                        switch coordinator.currentStatus {
                        case .loading:
                            ProgressView("Loading…")
                        default:
                            Text("Select a section from the sidebar")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .navigationTitle(coordinator.selectedRoute?.localizedName ?? "Velare")
            }
            .frame(minWidth: 600, minHeight: 600)
            .onAppear {
                Task { await coordinator.start() }
            }
        }
    }
}
