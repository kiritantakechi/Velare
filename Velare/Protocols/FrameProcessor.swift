//
//  FrameProcessor.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

protocol FrameProcessor {
    func process(_ frame: consuming VideoFrame) async throws -> VideoFrame
}
