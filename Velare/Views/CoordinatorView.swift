//
//  CoordinatorView.swift
//  Velare
//
//  Created by Kiritan on 2025/09/27.
//

import Combine
import SwiftUI

struct CoordinatorView: View {
    @State private var viewModel: CoordinatorViewModel
    
    init(viewModel: CoordinatorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GlassEffectContainer {
            NavigationSplitView {
                List(AppRoute.allCases, selection: $viewModel.selectedRoute) { route in
                    NavigationLink(value: route) {
                        Label(route.localizedName, systemImage: route.iconName)
                    }
                }
                .disabled(viewModel.isLoading)
                .navigationTitle("Velare")
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            } detail: {
                Group {
                    if let route = viewModel.selectedRoute {
                        switch route {
                        case .dashboard:
                            DashboardView(viewModel: viewModel.makeDashboardViewModel())
                        case .capture:
                            CaptureView(viewModel: viewModel.makeCaptureViewModel())
                        case .setting:
                            SettingView(viewModel: viewModel.makeSettingViewModel())
                        case .permission:
                            PermissionView(viewModel: viewModel.makePermissionViewModel())
                        }
                    } else {
                        switch viewModel.currentStatus {
                        case .loading:
                            ProgressView("Loading…")
                        default:
                            Text("Select a section from the sidebar")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .navigationTitle(viewModel.selectedRoute?.localizedName ?? "Velare")
            }
            .frame(minWidth: 600, minHeight: 600)
            .onAppear {
                viewModel.start()
            }
        }
    }
}
