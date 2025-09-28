//
//  CaptureViewModel.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

@Observable
final class CaptureViewModel {
    private var windowDiscoveryService = WindowDiscoveryService()

    var availableWindows: [WindowInfo] = []
    var selectedWindowID: CGWindowID? {
        didSet {
            if let windowID = selectedWindowID {
                windowDiscoveryService.selectWindow(by: windowID)
            } else {
                windowDiscoveryService.clearSelection()
            }
        }
    }

    var isRefreshing = false

    init(service: WindowDiscoveryService) {
        self.windowDiscoveryService = service
        refreshWindows()
    }

    func refreshWindows() {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        Task {
            await windowDiscoveryService.refreshAvailableContent()
        }
        
        availableWindows = windowDiscoveryService.availableWindows
        isRefreshing = false
    }

    func clearSelection() {
        selectedWindowID = nil
        windowDiscoveryService.clearSelection()
    }
}
