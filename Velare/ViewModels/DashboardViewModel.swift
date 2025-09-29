//
//  DashboardViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

@Observable
final class DashboardViewModel {
    private let coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
}
