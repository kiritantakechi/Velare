//
//  PermissionViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

@Observable
final class PermissionViewModel {
    private let permissionService: PermissionService

    var screenCapturePermissionStatus: PermissionStatus {
        permissionService.screenCapturePermissionStatus
    }

    var isPermissionGranted: Bool {
        permissionService.isPermissionGranted
    }

    init(permissionService: PermissionService) {
        self.permissionService = permissionService
        checkPermissions()
    }

    func checkPermissions() {
        permissionService.checkScreenCapturePermission()
    }

    func requestPermission() {
        _ = permissionService.requestScreenCapturePermission()

        checkPermissions()
    }

    func openSystemSettingsForScreenCapture() {
        permissionService.openSystemSettingsForScreenCapture()
    }
}
