//
//  WindowObservation.swift
//  Velare
//
//  Created by Kiritan on 2025/10/05.
//

import SwiftUI

struct WindowObservation: Hashable, Sendable {
    let id = UUID()
    let handler: (WindowEvent) -> Void

    init(_ handler: @escaping (WindowEvent) -> Void) {
        self.handler = handler
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: borrowing WindowObservation, rhs: borrowing WindowObservation) -> Bool {
        return lhs.id == rhs.id
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
