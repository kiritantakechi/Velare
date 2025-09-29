//
//  SettingView.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

struct SettingView: View {
    @State private var viewModel: SettingViewModel

    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
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
