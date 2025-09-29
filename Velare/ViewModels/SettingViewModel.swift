//
//  SettingViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

@Observable
final class SettingViewModel {
    private let coordinator: AppCoordinator
    private let settingService: SettingService
    
    var appLanguage: AppLanguage {
            get { settingService.appLanguage }
            set { settingService.appLanguage = newValue }
        }
        
        var isMetalFXEnabled: Bool {
            get { settingService.isMetalFXEnabled }
            set { settingService.isMetalFXEnabled = newValue }
        }
        
        var metalFXMode: MetalFXMode {
            get { settingService.metalFXMode }
            set { settingService.metalFXMode = newValue }
        }
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.settingService = coordinator.settingService
    }
}
