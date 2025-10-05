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
        if viewModel.texture != nil {
            MetalView(gpuContextPool: viewModel.gpuContextPool, texture: viewModel.texture)
                .ignoresSafeArea()
                .background(WindowAccessor(callback: viewModel.setWindow))
        }
        else {
            // FFFFFUCK SHIT CODE
            EmptyView()
                .ignoresSafeArea()
                .background(WindowAccessor(callback: viewModel.setWindow))
        }
    }
}
