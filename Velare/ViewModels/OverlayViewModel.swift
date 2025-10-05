//
//  OverlayViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import SwiftUI

@Observable
final class OverlayViewModel {
    private unowned let coordinator: AppCoordinator

    private unowned let overlayService: OverlayService
    unowned let gpuContextPool: GPUContextPool

    var texture: (any MTLTexture)? { overlayService.texture }

    init(coordinator: consuming AppCoordinator) {
        self.gpuContextPool = coordinator.gpuContextPool
        self.overlayService = coordinator.overlayService

        self.coordinator = consume coordinator
    }

    func setWindow(_ window: consuming NSWindow) {
        overlayService.setWindow(consume window)
    }
}
