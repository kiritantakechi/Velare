//
//  OverlayView.swift
//  Velare
//
//  Created by Kiritan on 2025/10/02.
//

import MetalKit
import SwiftUI

struct OverlayView: View {
    @State var viewModel: OverlayViewModel

    init(viewModel: OverlayViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        MetalView(cacheService: viewModel.cacheService, texture: viewModel.texture)
            .ignoresSafeArea()
            .background(WindowAccessor(callback: viewModel.setWindow)) // 用一个辅助视图来获取 NSWindow
    }
}
