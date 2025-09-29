//
//  DashboardView.swift
//  Velare
//
//  Created by Kiritan on 2025/09/28.
//

import SwiftUI

struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GlassEffectContainer {
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)
            }
            .padding()
        }
    }
}
