//
//  OverlayViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import SwiftUI

@Observable
final class OverlayViewModel {
    private let coordinator: AppCoordinator

    private let overlayService: OverlayService

    let cacheService: CacheService

    var texture: MTLTexture? {
        overlayService.texture
    }

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.cacheService = coordinator.cacheService
        self.overlayService = coordinator.overlayService
    }

    func setWindow(_ window: NSWindow) {
        overlayService.setWindow(window)
    }
}
