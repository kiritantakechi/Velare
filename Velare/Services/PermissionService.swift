//
//  PermissionService.swift
//  Velare
//
//  Created by Kiritan on 2025/09/29.
//

import SwiftUI

enum PermissionStatus: String, Hashable, Sendable {
    case unknown
    case denied
    case granted

    var id: String { rawValue }
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
        CGRequestScreenCaptureAccess()
    }

    func openSystemSettingsForScreenCapture() {
        let urlString: String
        if #available(macOS 13.0, *) {
            urlString = "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture"
        } else {
            urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
        }

        guard let url = URL(string: urlString) else {
            // In the unlikely event this fails, do nothing.
            return
        }
        NSWorkspace.shared.open(url)
    }
}
