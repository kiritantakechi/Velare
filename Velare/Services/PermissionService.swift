//
//  PermissionService.swift
//  Velare
//
//  Created by Kiritan on 2025/09/29.
//

import ApplicationServices
import SwiftUI

enum PermissionStatus: String, Hashable, Sendable {
    case unknown
    case denied
    case granted

    var id: String { rawValue }
}

@Observable
final class PermissionService {
    private(set) var accessibilityPermissionStatus: PermissionStatus = .unknown
    private(set) var screenCapturePermissionStatus: PermissionStatus = .unknown

    var isAccessibilityPermissionGranted: Bool {
        accessibilityPermissionStatus == .granted
    }

    var isScreenCapturePermissionGranted: Bool {
        screenCapturePermissionStatus == .granted
    }

    init() {
        checkPermissions()
    }

    func checkPermissions() {
        // 这里不请求，只检查
        checkScreenCapturePermission()
        checkAccessibilityPermission()
    }

    private func checkAccessibilityPermission() {
        if AXIsProcessTrusted() {
            accessibilityPermissionStatus = .granted
        } else {
            accessibilityPermissionStatus = .denied
        }
    }

    private func checkScreenCapturePermission() {
        if CGPreflightScreenCaptureAccess() {
            screenCapturePermissionStatus = .granted
        } else {
            screenCapturePermissionStatus = .denied
        }
    }

    // 缓解修复
    func requestAccessibilityPermission() -> Bool {
        let promptKey = "AXTrustedCheckOptionPrompt" as CFString
        let options: CFDictionary = [promptKey: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func requestScreenCapturePermission() -> Bool {
        CGRequestScreenCaptureAccess()
    }

    func openSystemSettingsForAccessibility() {
        let urlString = if #available(macOS 13.0, *) {
            "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility"
        } else {
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        }

        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    func openSystemSettingsForScreenCapture() {
        let urlString = if #available(macOS 13.0, *) {
            "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_ScreenCapture"
        } else {
            "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
        }

        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
}
