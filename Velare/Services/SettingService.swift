//
//  SettingService.swift
//  Velare
//
//  Created by Kiritan on 2025/09/29.
//

import SwiftUI

enum AppLanguage: String, CaseIterable, Hashable, Identifiable, Sendable {
    case systemDefault = "system"
    case german = "de"
    case english = "en"
    case french = "fr"
    case italian = "it"
    case japanese = "ja"
    case korean = "ko"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .systemDefault: return "setting.language.system"
        case .german: return "setting.language.german"
        case .english: return "setting.language.english"
        case .french: return "setting.language.french"
        case .italian: return "setting.language.italian"
        case .japanese: return "setting.language.japanese"
        case .korean: return "setting.language.korean"
        case .simplifiedChinese: return "setting.language.simplifiedChinese"
        case .traditionalChinese: return "setting.language.traditionalChinese"
        }
    }
}

enum UpscalingMode: String, CaseIterable, Hashable, Identifiable, Sendable {
    case performance
    case balanced
    case quality

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .performance: return "setting.metalfx.mode.performance"
        case .balanced: return "setting.metalfx.mode.balanced"
        case .quality: return "setting.metalfx.mode.quality"
        }
    }
}

enum HdrConversionModel: String, CaseIterable, Hashable, Identifiable, Sendable {
    case animeHdr

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .animeHdr: return "setting.hdr.model.animeHdr"
        }
    }
}

@Observable
final class SettingService {
    private enum Keys {
        private static let prefix = "com.touhouasia.Velare"

        static let appLanguage = "\(prefix).appLanguage"
        static let inputFramerate = "\(prefix).inputFramerate"
        static let isMetalFXUpscalingEnabled = "\(prefix).isMetalFXUpscalingEnabled"
        static let upscalingMode = "\(prefix).upscalingMode"
        static let isMetalFXFrameInterpolationEnabled = "\(prefix).isMetalFXFrameInterpolationEnabled"
        static let isSdrToHdrConversionEnabled = "\(prefix).isSdrToHdrConversionEnabled"
        static let hdrConversionModel = "\(prefix).hdrConversionModel"
    }

    var appLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.setValue(appLanguage.rawValue, forKey: Keys.appLanguage)
            // 你可以在这里发布一个通知，让App的其他部分响应语言变化
        }
    }

    var activeLocale: Locale {
        // 如果设置为“跟随系统”，则返回系统当前的 locale
        guard appLanguage != .systemDefault else {
            return Locale.autoupdatingCurrent
        }
        // 否则，根据我们枚举的 rawValue 创建一个指定的 locale
        return Locale(identifier: appLanguage.rawValue)
    }
    
    var inputFramerate: Int {
        didSet {
            UserDefaults.standard.setValue(inputFramerate, forKey: Keys.inputFramerate)
        }
    }

    var isMetalFXUpscalingEnabled: Bool {
        didSet {
            UserDefaults.standard.setValue(isMetalFXUpscalingEnabled, forKey: Keys.isMetalFXUpscalingEnabled)
        }
    }

    var upscalingMode: UpscalingMode {
        didSet {
            UserDefaults.standard.setValue(upscalingMode.rawValue, forKey: Keys.upscalingMode)
        }
    }

    var isMetalFXFrameInterpolationEnabled: Bool {
        didSet {
            UserDefaults.standard.setValue(isMetalFXFrameInterpolationEnabled, forKey: Keys.isMetalFXFrameInterpolationEnabled)
        }
    }

    var isSdrToHdrConversionEnabled: Bool {
        didSet {
            UserDefaults.standard.setValue(isSdrToHdrConversionEnabled, forKey: Keys.isSdrToHdrConversionEnabled)
        }
    }

    var hdrConversionModel: HdrConversionModel {
        didSet {
            UserDefaults.standard.setValue(hdrConversionModel.rawValue, forKey: Keys.hdrConversionModel)
        }
    }

    init() {
        UserDefaults.standard.register(defaults: [
            Keys.appLanguage: AppLanguage.systemDefault.rawValue,
            Keys.inputFramerate: 60,
            Keys.isMetalFXUpscalingEnabled: false,
            Keys.upscalingMode: UpscalingMode.balanced.rawValue,
            Keys.isMetalFXFrameInterpolationEnabled: false,
            Keys.isSdrToHdrConversionEnabled: false,
            Keys.hdrConversionModel: HdrConversionModel.animeHdr.rawValue
        ])

        // Load values safely, falling back to registered defaults if anything goes wrong.
        self.appLanguage = UserDefaults.standard.string(forKey: Keys.appLanguage).flatMap(AppLanguage.init) ?? .systemDefault
        self.inputFramerate = UserDefaults.standard.integer(forKey: Keys.inputFramerate)
        self.isMetalFXUpscalingEnabled = UserDefaults.standard.bool(forKey: Keys.isMetalFXUpscalingEnabled)
        self.upscalingMode = UserDefaults.standard.string(forKey: Keys.upscalingMode).flatMap(UpscalingMode.init) ?? .balanced
        self.isMetalFXFrameInterpolationEnabled = UserDefaults.standard.bool(forKey: Keys.isMetalFXFrameInterpolationEnabled)
        self.isSdrToHdrConversionEnabled = UserDefaults.standard.bool(forKey: Keys.isSdrToHdrConversionEnabled)
        self.hdrConversionModel = UserDefaults.standard.string(forKey: Keys.hdrConversionModel).flatMap(HdrConversionModel.init) ?? .animeHdr
    }
}
