//
//  WindowObserverService.swift
//  Velare
//
//  Created by Kiritan on 2025/10/05.
//

import AppKit
import Foundation
import SwiftUI

@Observable
final class WindowObserverService {
    private var observations: [WindowObservation] = []
    private var workspaceNotifications: [any NSObjectProtocol] = []
    private let queue = DispatchQueue(label: "app.velare.window-observer")
    
    private var isObserving: Bool = false

    init() {
        startObserve()
    }
    
    deinit {
        stopObserve()
    }
    
    func startObserve() {
        guard !isObserving else { return }
        isObserving = true
            
        // 注册 macOS Workspace 通知（应用层事件）
        let nc = NSWorkspace.shared.notificationCenter
        workspaceNotifications = [
            nc.addObserver(forName: NSWorkspace.activeSpaceDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
                self?.emitAllVisibleWindows()
            }
        ]
            
        // 注册窗口层通知（通过 AX API）
        setupAccessibilityObservers()
            
        print("[WindowObserverService] started.")
    }
        
    func stopObserve() {
        guard isObserving else { return }
        isObserving = false
            
        let nc = NSWorkspace.shared.notificationCenter
        workspaceNotifications.forEach { nc.removeObserver($0) }
        workspaceNotifications.removeAll()
            
        print("[WindowObserverService] stopped.")
    }
    
    func subscribe(_ handler: @escaping (WindowEvent) -> Void) -> UUID {
        let obs = WindowObservation(handler)
        observations.append(obs)
        return obs.id
    }
        
    func unsubscribe(_ id: UUID) {
        observations.removeAll { $0.id == id }
    }

    private func emit(_ event: WindowEvent) {
        for obs in observations {
            obs.handler(event)
        }
    }

    private func emitAllVisibleWindows() {
        guard let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else { return }

        for info in windowList {
            if let windowID = info[kCGWindowNumber as String] as? CGWindowID {
                emit(.created(windowID: windowID))
            }
        }
    }
    
    private func setupAccessibilityObservers() {
        // 使用 AXObserver 监听窗口变化（需要辅助功能权限）
        guard AXIsProcessTrusted() else {
            print("[WindowObserverService] 辅助功能未授权。")
            return
        }
            
        let apps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }
            
        for app in apps {
            guard let pid = app.processIdentifier as pid_t? else { continue }
                
            var axApp: AXUIElement?
            axApp = AXUIElementCreateApplication(pid)
                
            var observer: AXObserver?
            let result = unsafe AXObserverCreate(pid, { _, element, notification, context in
                let service = unsafe Unmanaged<WindowObserverService>.fromOpaque(context!).takeUnretainedValue()
                service.handleAXEvent(element: element, notification: notification as CFString)
            }, &observer)
                
            guard result == .success, let observer else { continue }
                
            let context = unsafe UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
                
            unsafe AXObserverAddNotification(observer, axApp!, kAXWindowCreatedNotification as CFString, context)
            unsafe AXObserverAddNotification(observer, axApp!, kAXUIElementDestroyedNotification as CFString, context)
            unsafe AXObserverAddNotification(observer, axApp!, kAXMovedNotification as CFString, context)
            unsafe AXObserverAddNotification(observer, axApp!, kAXResizedNotification as CFString, context)
            unsafe AXObserverAddNotification(observer, axApp!, kAXFocusedWindowChangedNotification as CFString, context)
                
            CFRunLoopAddSource(CFRunLoopGetMain(),
                               AXObserverGetRunLoopSource(observer),
                               .defaultMode)
        }
    }
    
    private func handleAXEvent(element: AXUIElement, notification: CFString) {
        var windowID: CGWindowID = 0
        
        let kAXWindowNumberAttribute = "AXWindowNumber" as CFString
        var value: CFTypeRef?
        if unsafe AXUIElementCopyAttributeValue(element, kAXWindowNumberAttribute, &value) == .success,
           let number = value as? NSNumber
        {
            windowID = CGWindowID(number.uint32Value)
            print("窗口 ID: \(windowID)")
        }
            
        switch notification as String {
        case kAXWindowCreatedNotification: emit(.created(windowID: windowID))
        case kAXUIElementDestroyedNotification: emit(.closed(windowID: windowID))
        case kAXMovedNotification: emit(.moved(windowID: windowID))
        case kAXResizedNotification: emit(.resized(windowID: windowID))
        case kAXFocusedWindowChangedNotification: emit(.focused(windowID: windowID))
        default: break
        }
    }
}
