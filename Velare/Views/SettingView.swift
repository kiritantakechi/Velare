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
            Form {
                Section(header: Text("setting.view.section.general")) {
                    Picker("setting.view.languagePicker.label", selection: $viewModel.appLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(LocalizedStringKey(language.localizationKey)).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("setting.view.section.videoProcessing")) {
                    // --- 通用视频设置 ---
                    Stepper(
                        "setting.view.framerate.label: \(viewModel.inputFramerate) FPS",
                        value: $viewModel.inputFramerate,
                        in: 24 ... 144
                    )

                    // Divider()

                    // --- MetalFX 性能增强 ---
                    Toggle(isOn: $viewModel.isMetalFXUpscalingEnabled) {
                        Text("setting.view.metalfx.upscaling.label")
                        Text("setting.view.metalfx.upscaling.description")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    // MetalFX 模式选择，紧跟其主开关
                    Picker("setting.view.metalfx.modePicker.label", selection: $viewModel.upscalingMode) {
                        ForEach(UpscalingMode.allCases) { mode in
                            Text(LocalizedStringKey(mode.localizationKey)).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(!viewModel.isMetalFXUpscalingEnabled)

                    Toggle(isOn: $viewModel.isMetalFXFrameInterpolationEnabled) {
                        Text("setting.view.metalfx.frameInterpolation.label")
                        Text("setting.view.metalfx.frameInterpolation.description")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    // Divider()

                    // --- SDR 到 HDR 转换 ---
                    Toggle(isOn: $viewModel.isSdrToHdrConversionEnabled) {
                        Text("setting.view.sdrToHdr.label")
                        Text("setting.view.sdrToHdr.description")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    // HDR 转换模型选择
                    Picker("setting.view.hdrModel.label", selection: $viewModel.hdrConversionModel) {
                        ForEach(HdrConversionModel.allCases) { model in
                            Text(LocalizedStringKey(model.localizationKey)).tag(model)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(!viewModel.isSdrToHdrConversionEnabled)
                }
            }
            .formStyle(.grouped)
            .padding()
        }
    }
}
