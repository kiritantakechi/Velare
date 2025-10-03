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
    
    var screenCapturePermissionStatus: PermissionStatus { permissionService.screenCapturePermissionStatus }
    
    var isScreenCapturePermissionGranted: Bool { permissionService.isScreenCapturePermissionGranted }
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.permissionService = coordinator.permissionService
        checkPermissions()
    }
    
    func checkPermissions() {
        // 这里不请求，只检查
        permissionService.checkPermissions()
    }
    
    func requestScreenCapturePermission() {
        _ = permissionService.requestScreenCapturePermission()
        
        checkPermissions()
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
