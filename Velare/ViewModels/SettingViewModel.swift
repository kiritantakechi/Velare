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
    
    var inputFramerate: Int {
        get { settingService.inputFramerate }
        set { settingService.inputFramerate = newValue }
    }
        
    var isMetalFrameGenerationEnabled: Bool {
        get { settingService.isMetalFrameGenerationEnabled }
        set { settingService.isMetalFrameGenerationEnabled = newValue }
    }
        
    var isSdrToHdrConversionEnabled: Bool {
        get { settingService.isSdrToHdrConversionEnabled }
        set { settingService.isSdrToHdrConversionEnabled = newValue }
    }

    var hdrConversionModel: HdrConversionModel {
        get { settingService.hdrConversionModel }
        set { settingService.hdrConversionModel = newValue }
    }
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.settingService = coordinator.settingService
    }
}
