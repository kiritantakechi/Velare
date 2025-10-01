//
//  ProcessingService.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import SwiftUI

@Observable
final class ProcessingService {
    private var processors: [FrameProcessor] = []

        // 在运行时根据设置来构建处理队列
        init(setting: SettingService) {
            if setting.isSdrToHdrConversionEnabled {
                // 假设一个 SDRtoHDRProcessor
                // processors.append(SDRtoHDRProcessor(model: setting.hdrConversionModel))
            }
            if setting.isMetalFXUpscalingEnabled {
                // 假设一个 MetalFXUpscalingProcessor
                // processors.append(MetalFXUpscalingProcessor(mode: setting.upscalingMode))
            }
            if setting.isMetalFXFrameInterpolationEnabled {
                // 假设一个 FrameInterpolationProcessor
                // processors.append(FrameInterpolationProcessor())
            }
        }

        // 依次执行所有处理
        func process(_ frame: VideoFrame) async throws -> VideoFrame {
            var currentFrame = frame
            for processor in processors {
                currentFrame = try await processor.process(currentFrame)
            }
            return currentFrame
        }
}
