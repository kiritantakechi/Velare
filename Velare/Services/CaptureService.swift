//
//  CaptureService.swift
//  Velare
//
//  Created by Kiritan on 2025/10/01.
//

import SwiftUI

@Observable
final class CaptureService {
    private(set) var isCapturing: Bool = false

    func toggleCapture(by windowID: CGWindowID) {
        isCapturing.toggle()

        if isCapturing {
            // 在这里开始捕获的逻辑...
            print("开始捕获窗口: \(windowID)")
        } else {
            // 在这里停止捕获的逻辑...
            print("停止捕获。")
        }
    }
}
