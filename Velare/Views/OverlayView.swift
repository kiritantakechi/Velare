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
        let metalViewModel = MetalViewModel(cacheService: viewModel.cacheService)
        
        MetalView(viewModel: metalViewModel, texture: viewModel.texture)
            .ignoresSafeArea()
            .background(WindowAccessor(callback: viewModel.setWindow)) // 用一个辅助视图来获取 NSWindow
    }
}
