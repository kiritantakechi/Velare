//
//  WindowObservation.swift
//  Velare
//
//  Created by Kiritan on 2025/10/05.
//

import SwiftUI

struct WindowObservation: Sendable {
    let id = UUID()
    let handler: (WindowEvent) -> Void

    init(_ handler: @escaping (WindowEvent) -> Void) {
        self.handler = handler
    }
}

enum WindowEvent {
    case created(windowID: CGWindowID)
    case moved(windowID: CGWindowID)
    case resized(windowID: CGWindowID)
    case closed(windowID: CGWindowID)
    case focused(windowID: CGWindowID)
    case unfocused(windowID: CGWindowID)
}
