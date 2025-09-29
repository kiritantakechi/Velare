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
                        Label(
                            LocalizedStringKey(route.localizationKey),
                            systemImage: route.iconName
                        )
                    }
                }
                .scrollIndicators(.hidden)
                .disabled(viewModel.isLoading)
                .navigationTitle("coordinator.view.navigation.title")
                .navigationSplitViewColumnWidth(min: 160, ideal: 200)
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
                        if viewModel.isLoading {
                            ProgressView("coordinator.view.detail.loading")
                        } else {
                            Text("coordinator.view.detail.selectionPrompt")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
//                // 无法解决的 Bug
//                .navigationTitle(
//                    LocalizedStringKey(viewModel.selectedRoute?.localizationKey ?? "coordinator.view.navigation.title")
//                )
            }
            .frame(minWidth: 600, minHeight: 480)
            .onAppear {
                viewModel.start()
            }
            .environment(\.locale, viewModel.activeLocale)
        }
    }
}
