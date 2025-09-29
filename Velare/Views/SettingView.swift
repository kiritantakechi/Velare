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
                Section(header: Text("setting.view.section.general")) {
                    Picker("setting.view.languagePicker.label", selection: $viewModel.appLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(
                                LocalizedStringKey(language.localizationKey)
                            )
                            .tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: 300) // 限制选择器的宽度
                }
                Section(header: Text("setting.view.section.videoEnhancement")) {
                    // MetalFX 开关
                    Toggle(isOn: $viewModel.isMetalFXEnabled) {
                        Text("setting.view.metalfx.enable.label")
                        Text("setting.view.metalfx.enable.description")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    // MetalFX 模式选择
                    Picker("setting.view.metalfx.modePicker.label", selection: $viewModel.metalFXMode) {
                        ForEach(MetalFXMode.allCases) { mode in
                            Text(
                                LocalizedStringKey(mode.localizationKey)
                            )
                            .tag(mode)
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
