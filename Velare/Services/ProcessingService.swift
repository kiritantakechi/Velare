//
//  ProcessingService.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import SwiftUI

@Observable
final class ProcessingService {
    private let settingService: SettingService

    private var processors: [any FrameProcessor] = []

    // 在运行时根据设置来构建处理队列
    init(SettingService: SettingService) {
        self.settingService = SettingService

        if settingService.isSdrToHdrConversionEnabled {
            // 假设一个 SDRtoHDRProcessor
            // processors.append(SDRtoHDRProcessor(model: setting.hdrConversionModel))
        }
        if settingService.isMetalFXUpscalingEnabled {
            // 假设一个 MetalFXUpscalingProcessor
            // processors.append(MetalFXUpscalingProcessor(mode: setting.upscalingMode))
        }
        if settingService.isMetalFXFrameInterpolationEnabled {
            // 假设一个 FrameInterpolationProcessor
            // processors.append(FrameInterpolationProcessor())
        }
    }

    // 依次执行所有处理
    func process(_ frame: consuming VideoFrame) async throws -> VideoFrame {
        var currentFrame = frame
        for processor in processors {
            currentFrame = try await processor.process(consume currentFrame)
        }
        return currentFrame
    }
}
