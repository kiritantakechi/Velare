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
    case japanese = "ja"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .systemDefault: return "跟随系统 (System)"
        case .english: return "English"
        case .japanese: return "日本語"
        case .simplifiedChinese: return "简体中文"
        case .traditionalChinese: return "繁體中文"
        }
    }
}

enum MetalFXMode: String, CaseIterable, Hashable, Identifiable, Sendable {
    case performance
    case balanced
    case quality

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .performance: return "性能优先 (Performance)"
        case .balanced: return "平衡 (Balanced)"
        case .quality: return "质量优先 (Quality)"
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
