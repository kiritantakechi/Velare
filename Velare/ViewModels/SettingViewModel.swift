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
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
}
