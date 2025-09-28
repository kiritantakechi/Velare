//
//  PermissionService.swift
//  Velare
//
//  Created by Kiritan on 2025/09/29.
//

import SwiftUI

enum PermissionStatus: Sendable {
    case unknown
    case denied
    case granted
}

@Observable
final class PermissionService {
    private(set) var screenCapturePermissionStatus: PermissionStatus = .unknown

    var isScreenCapturePermissionGranted: Bool {
        screenCapturePermissionStatus == .granted
    }

    func checkPermissions() {
        // 这里不请求，只检查

        if CGPreflightScreenCaptureAccess() {
            screenCapturePermissionStatus = .granted
        } else {
            screenCapturePermissionStatus = .denied
        }

        // 其他权限
    }

    func requestScreenCapturePermission() -> Bool {
        return CGRequestScreenCaptureAccess()
    }

    func openSystemSettingsForScreenCapture() {
        if #available(macOS 13.0, *) {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture")!)
        } else {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
        }
    }
}
