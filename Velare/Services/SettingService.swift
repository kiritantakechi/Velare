//
//  SettingService.swift
//  Velare
//
//  Created by Kiritan on 2025/09/29.
//

import SwiftUI

enum AppLanguage: String, CaseIterable, Hashable, Identifiable, Sendable {
    case systemDefault = "system"
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case japanese = "ja"
    case korean = "ko"

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .systemDefault: return "setting.language.system"
        case .english: return "setting.language.english"
        case .simplifiedChinese: return "setting.language.simplifiedChinese"
        case .traditionalChinese: return "setting.language.traditionalChinese"
        case .french: return "setting.language.french"
        case .german: return "setting.language.german"
        case .italian: return "setting.language.italian"
        case .japanese: return "setting.language.japanese"
        case .korean: return "setting.language.korean"
        }
    }
}

enum MetalFXMode: String, CaseIterable, Hashable, Identifiable, Sendable {
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

@Observable
final class SettingService {
    private enum Keys {
        static let appLanguage = "appLanguage"
        static let isMetalFXEnabled = "isMetalFXEnabled"
        static let metalFXMode = "metalFXMode"
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

    var isMetalFXEnabled: Bool {
        didSet {
            UserDefaults.standard.setValue(isMetalFXEnabled, forKey: Keys.isMetalFXEnabled)
        }
    }

    var metalFXMode: MetalFXMode {
        didSet {
            UserDefaults.standard.setValue(metalFXMode.rawValue, forKey: Keys.metalFXMode)
        }
    }

    init() {
        // 从 UserDefaults 加载已保存的设置，如果没有则使用默认值
        self.appLanguage = AppLanguage(rawValue: UserDefaults.standard.string(forKey: Keys.appLanguage) ?? "system") ?? .systemDefault
        self.isMetalFXEnabled = UserDefaults.standard.bool(forKey: Keys.isMetalFXEnabled)
        self.metalFXMode = MetalFXMode(rawValue: UserDefaults.standard.string(forKey: Keys.metalFXMode) ?? "quality") ?? .quality
    }
}
