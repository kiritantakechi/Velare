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
            VStack(spacing: 0) {
                // 1. Header
                VStack {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.accentColor)
                    
                    Text("permission.view.title")
                        .font(.largeTitle.bold())
                        .padding(.top, 10)
                    
                    Text("permission.view.description")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                }
                .padding(50)
                
                Divider()
                
                // 2. Permission Checklist
                VStack(spacing: 20) {
                    PermissionRow(viewModel: viewModel, type: .screenCapture)
                    PermissionRow(viewModel: viewModel, type: .accessibility)
                }
                .padding(30)
                
                Divider()
                
                // 3. Footer Action
                HStack {
                    Spacer()
                    Button(action: viewModel.permissionsGranted) {
                        Label("permission.view.button.continue", systemImage: "arrow.right.circle.fill")
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.isScreenCapturePermissionGranted || !viewModel.isAccessibilityPermissionGranted)
                }
                .padding(20)
            }
        }
        .onAppear(perform: viewModel.onAppear)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            viewModel.checkPermissions()
        }
    }
}

// Enum to represent the two types of permissions
private enum PermissionType {
    case screenCapture
    case accessibility
}

// A reusable view for a single permission item in the checklist
private struct PermissionRow: View {
    let viewModel: PermissionViewModel
    let type: PermissionType
    
    private var status: PermissionStatus {
        switch type {
        case .screenCapture: return viewModel.screenCapturePermissionStatus
        case .accessibility: return viewModel.accessibilityPermissionStatus
        }
    }
    
    private var title: LocalizedStringKey {
        switch type {
        case .screenCapture: return "permission.view.screenCapture.title"
        case .accessibility: return "permission.view.accessibility.title"
        }
    }
    
    private var subtitle: LocalizedStringKey {
        switch type {
        case .screenCapture: return "permission.view.screenCapture.subtitle"
        case .accessibility: return "permission.view.accessibility.subtitle"
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            Image(systemName: status == .granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(status == .granted ? .green : .secondary)
                .frame(width: 30)
            
            // Text
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Action Button
            actionButton
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch status {
        case .granted:
            Text("permission.view.status.granted")
                .foregroundStyle(.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            
        case .unknown:
            Button("permission.view.status.grant") { requestPermission() }
                .buttonStyle(.borderedProminent)
            
        case .denied:
            Button("permission.view.button.openSetting") { requestPermission(); openSettings() }
                .buttonStyle(.bordered)
        }
    }
    
    private func requestPermission() {
        switch type {
        case .screenCapture: viewModel.requestScreenCapturePermission()
        case .accessibility: viewModel.requestAccessibilityPermission()
        }
    }
    
    private func openSettings() {
        switch type {
        case .screenCapture: viewModel.openSystemSettingsForScreenCapture()
        case .accessibility: viewModel.openSystemSettingsForAccessibility()
        }
    }
}
