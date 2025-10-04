//
//  CaptureView.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI
internal import ScreenCaptureKit

struct CaptureView: View {
    @State private var viewModel: CaptureViewModel

    init(viewModel: CaptureViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GlassEffectContainer {
            VStack {
                List(viewModel.availableWindows, id: \.windowID, selection: $viewModel.selectedWindowID) { window in
                    HStack {
                        Text(window.owningApplication?.applicationName ?? "Unknown")
                            .font(.body)
                        Spacer()
                        Text(window.title ?? "")
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
                        if !viewModel.isCapturing {
                            viewModel.startCapture()
                        } else {
                            viewModel.stopCapture()
                        }
                    }) {
                        Image(systemName: viewModel.isCapturing ? "stop.circle.fill" : "play.circle.fill")
                    }
                    .disabled(viewModel.selectedWindowID == nil)
                }
            }
            .animation(.easeInOut, value: viewModel.isCapturing)
            .onAppear { viewModel.onAppear() }
        }
    }
}
