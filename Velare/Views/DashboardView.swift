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
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 20) {
                    cpuCard
                    memoryCard
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }

    private var cpuCard: some View {
        MetricCard(
            title: LocalizedStringKey("dashboard.view.cpuCard.title"),
            iconName: "cpu",
            iconColor: .blue,
            valueText: viewModel.cpuUsagePercentage
        ) {
            Gauge(value: viewModel.cpuUsage, in: 0...1) {}
                .gaugeStyle(.accessoryLinear)
                .tint(.blue)
        }
    }

    private var memoryCard: some View {
        MetricCard(
            title: LocalizedStringKey("dashboard.view.memoryCard.title"),
            iconName: "memorychip",
            iconColor: .green,
            valueText: viewModel.memoryUsageDescription
        ) {
            Gauge(value: viewModel.memoryUsage.usagePercentage, in: 0...1) {}
                .gaugeStyle(.accessoryLinear)
                .tint(.green)
        }
    }
}

struct MetricCard<Content: View>: View {
    let title: LocalizedStringKey
    let iconName: String
    let iconColor: Color
    let valueText: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 30)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text(valueText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            content
        }
        .padding()
        .background(.background.opacity(0.5)) // 半透明背景
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

//#Preview {
//    let service = SystemMonitorService()
//    let viewModel = DashboardViewModel(monitorService: service)
//    DashboardView(viewModel: viewModel)
//        .frame(width: 600, height: 400)
//}
