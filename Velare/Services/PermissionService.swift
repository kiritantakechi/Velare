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

    var isPermissionGranted: Bool {
        screenCapturePermissionStatus == .granted
    }

    func checkScreenCapturePermission() {
        if CGPreflightScreenCaptureAccess() {
            screenCapturePermissionStatus = .granted
        } else {
            screenCapturePermissionStatus = .denied
        }
    }

    func requestScreenCapturePermission() -> Bool {
        return CGRequestScreenCaptureAccess()
    }

    func openSystemSettingsForScreenCapture() {
        if #available(macOS 13.0, *) {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?id=com.apple.preference.security.Privacy_ScreenCapture")!)
        } else {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
        }
    }
}
