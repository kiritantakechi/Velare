//
//  SettingView.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

struct SettingView: View {
    @Bindable var coordinator: AppCoordinator
    @State private var viewModel: SettingViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.viewModel = coordinator.makeSettingViewModel()
    }

    var body: some View {
        GlassEffectContainer {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                // 设置项...
            }
            .padding()
        }
    }
}
