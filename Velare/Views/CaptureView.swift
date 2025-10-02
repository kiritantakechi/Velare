//
//  CaptureView.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

struct CaptureView: View {
    @State private var viewModel: CaptureViewModel

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    init(viewModel: CaptureViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GlassEffectContainer {
            VStack {
                List(viewModel.availableWindows, id: \.id, selection: $viewModel.selectedWindowID) { window in
                    HStack {
                        Text(window.appName)
                            .font(.body)
                        Spacer()
                        Text(window.title)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.bordered(alternatesRowBackgrounds: true))
                .scrollIndicators(.hidden)
                .opacity(viewModel.isCapturing ? 0.5 : 1.0)
                .disabled(viewModel.isCapturing)
            }
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: { viewModel.refreshWindows() }) {
                        Image(systemName: "arrow.clockwise")
                            .opacity(viewModel.isRefreshing ? 0 : 1)
                            .overlay {
                                if viewModel.isRefreshing {
                                    ProgressView()
                                        .controlSize(.small)
                                }
                            }
                    }
                    .disabled(viewModel.isRefreshing || viewModel.isCapturing)

                    Button(action: {
                        if viewModel.isCapturing {
                            // 如果正在捕获，就停止并关闭窗口
                            viewModel.toggleCapture()
                            dismissWindow(id: "overlay-window")
                        } else {
                            // 如果尚未捕获，就打开窗口并开始
                            openWindow(id: "overlay-window")
                            viewModel.toggleCapture()
                        }
                    }) {
                        Image(systemName: viewModel.isCapturing ? "stop.circle.fill" : "play.circle.fill")
                    }
                    .disabled(viewModel.selectedWindowID == nil)
                }
            }
            .animation(.easeInOut, value: viewModel.isCapturing)
        }
    }
}
