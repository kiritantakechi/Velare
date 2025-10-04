//
//  SettingViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

@Observable
final class SettingViewModel {
    private unowned let coordinator: AppCoordinator
    private unowned let settingService: SettingService
    
    var appLanguage: AppLanguage {
        get { settingService.appLanguage }
        set { settingService.appLanguage = newValue }
    }
    
    var inputFramerate: Int {
        get { settingService.inputFramerate }
        set { settingService.inputFramerate = newValue }
    }
        
    var isMetalFXUpscalingEnabled: Bool {
        get { settingService.isMetalFXUpscalingEnabled }
        set { settingService.isMetalFXUpscalingEnabled = newValue }
    }
        
    var upscalingMode: UpscalingMode {
        get { settingService.upscalingMode }
        set { settingService.upscalingMode = newValue }
    }
        
    var isMetalFXFrameInterpolationEnabled: Bool {
        get { settingService.isMetalFXFrameInterpolationEnabled }
        set { settingService.isMetalFXFrameInterpolationEnabled = newValue }
    }
        
    var isSdrToHdrConversionEnabled: Bool {
        get { settingService.isSdrToHdrConversionEnabled }
        set { settingService.isSdrToHdrConversionEnabled = newValue }
    }

    var hdrConversionModel: HdrConversionModel {
        get { settingService.hdrConversionModel }
        set { settingService.hdrConversionModel = newValue }
    }
    
    init(coordinator: consuming AppCoordinator) {
        self.settingService = coordinator.settingService
        self.coordinator = consume coordinator
    }
}
