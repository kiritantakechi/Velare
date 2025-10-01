//
//  PermissionView.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

struct PermissionView: View {
    @State private var viewModel: PermissionViewModel

    init(viewModel: PermissionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "hand.raised.square.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(Color.accentColor)
                    .padding(.bottom, 10)

                Text("permission.view.title")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("permission.view.description")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Spacer()

                // 主操作按钮
                mainActionButton
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                // 辅助操作：仅在用户已明确拒绝权限后显示
                if viewModel.isScreenCapturePermissionGranted == false {
                    secondaryActionButton
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                
                Spacer()
            }
            .padding()
            // 当应用从后台回到前台时（例如从系统设置回来），重新检查权限
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                viewModel.checkPermissions()
            }
        }
    }

    @ViewBuilder
    private var mainActionButton: some View {
        if viewModel.isScreenCapturePermissionGranted {
            // --- 状态：已授权 ---
            Button(action: {
                viewModel.permissionsGranted()
            }) {
                Label("permission.view.button.granted", systemImage: "checkmark.circle.fill")
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .tint(.green)
        } else {
            // --- 状态：未授权 (可能是初次，也可能是已拒绝) ---
            Button(action: {
                // 点击后会触发系统弹窗
                viewModel.requestScreenCapturePermission()
            }) {
                Label("permission.view.button.grant", systemImage: "lock.shield.fill")
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    private var secondaryActionButton: some View {
        Button("permission.view.button.openSetting") {
            viewModel.openSystemSettingsForScreenCapture()
        }
        .buttonStyle(.link)
    }
}
