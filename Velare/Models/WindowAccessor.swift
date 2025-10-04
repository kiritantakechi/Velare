//
//  WindowAccessor.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import SwiftUI

struct WindowAccessor: NSViewRepresentable, Sendable {
    var callback: (NSWindow) -> Void

    func makeNSView(context: consuming Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = unsafe view.window {
                self.callback(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: consuming NSView, context: consuming Context) {
//        DispatchQueue.main.async {
//            if let window = unsafe nsView.window {
//                self.callback(window)
//            }
//        }
    }
}
