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
            // Form 会自动提供平台原生的列表样式
            Form {
                Section(header: Text("通用 (General)")) {
                    Picker("语言 (Language)", selection: $viewModel.appLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.localizedName).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 300) // 限制选择器的宽度
                }
                Section(header: Text("视频增强 (Video Enhancement)")) {
                    // MetalFX 开关
                    Toggle(isOn: $viewModel.isMetalFXEnabled) {
                        Text("启用 MetalFX 缩放")
                        Text("使用 Apple Silicon 的性能提升视频分辨率，可能会增加功耗。")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    // MetalFX 模式选择
                    Picker("模式 (Mode)", selection: $viewModel.metalFXMode) {
                        ForEach(MetalFXMode.allCases) { mode in
                            Text(mode.localizedName).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 300)
                    // 当 MetalFX 未启用时，禁用这个 Picker
                    .disabled(!viewModel.isMetalFXEnabled)
                    .tint(viewModel.isMetalFXEnabled ? .primary : .secondary)
                }
            }
            .formStyle(.grouped) // 提供分组样式
            .padding()
        }
    }
}
