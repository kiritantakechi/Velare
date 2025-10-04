//
//  PermissionViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

@Observable
final class PermissionViewModel {
    private unowned let coordinator: AppCoordinator

    private unowned let permissionService: PermissionService
    
    var accessibilityPermissionStatus: PermissionStatus { permissionService.accessibilityPermissionStatus }
    var screenCapturePermissionStatus: PermissionStatus { permissionService.screenCapturePermissionStatus }
    
    var isAccessibilityPermissionGranted: Bool { permissionService.isAccessibilityPermissionGranted }
    var isScreenCapturePermissionGranted: Bool { permissionService.isScreenCapturePermissionGranted }
    
    init(coordinator: consuming AppCoordinator) {
        self.permissionService = coordinator.permissionService

        self.coordinator = consume coordinator
    }
    
    func onAppear() {
        checkPermissions()
    }
    
    func checkPermissions() {
        // 这里不请求，只检查
        permissionService.checkPermissions()
    }
    
    func requestAccessibilityPermission() {
        defer { checkPermissions() }
        
        guard permissionService.requestAccessibilityPermission() else { return }
    }
    
    func requestScreenCapturePermission() {
        defer { checkPermissions() }
        
        guard permissionService.requestScreenCapturePermission() else { return }
    }
    
    func openSystemSettingsForAccessibility() {
        permissionService.openSystemSettingsForAccessibility()
    }
    
    func openSystemSettingsForScreenCapture() {
        permissionService.openSystemSettingsForScreenCapture()
    }
    
    func permissionsGranted() {
        coordinator.permissionsGranted()
    }
    
    func permissionsDenied() {
        coordinator.permissionsDenied()
    }
}
