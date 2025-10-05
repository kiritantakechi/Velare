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
//        // 缓解修复
//        if viewModel.texture != nil {
//            MetalView(gpuPool: viewModel.gpuPool, texture: Binding(get: { viewModel.texture }, set: { _ in }))
//                .ignoresSafeArea()
//                .background(WindowAccessor(callback: viewModel.setWindow))
//        }
//        else {
//            // FFFFFUCK SHIT CODE
//            EmptyView()
//                .ignoresSafeArea()
//                .background(WindowAccessor(callback: viewModel.setWindow))
//        }

        MetalView(gpuPool: viewModel.gpuPool, texture: Binding(get: { viewModel.texture }, set: { _ in }))
            .ignoresSafeArea()
            .background(WindowAccessor(callback: viewModel.setWindow))
    }
}
