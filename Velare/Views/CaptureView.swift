//
//  CaptureView.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

struct CaptureView: View {
    @State private var viewModel: CaptureViewModel

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
            }
            .padding()
            .toolbar {
                ToolbarItem {
                    Spacer()
                }
                ToolbarItem {
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
                    .disabled(viewModel.isRefreshing)
                }
            }
        }
    }
}
