//
//  ContentView.swift
//  Aura
//
//  Created by Jency on 10/02/26.
//

import SwiftUI
import Charts

struct MainAuraView: View {
    @State private var viewModel = AuraViewModel()
    @Namespace private var auraNamespace
    
    var body: some View {
        ZStack {
            // Background remains consistent
            backgroundLayer
            
            if !viewModel.showDetails {
                // STATE 1: The Floating Orb (Home)
                VStack {
                    Spacer()
                    orbView
                        .matchedGeometryEffect(id: "auraShape", in: auraNamespace)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                viewModel.showDetails = true
                            }
                        }
                    Spacer()
                }
            } else {
                // STATE 2: The Full Screen Card (Detail)
                VStack {
                    detailCardView
                        .matchedGeometryEffect(id: "auraShape", in: auraNamespace)
                }
                .transition(.asymmetric(insertion: .identity, removal: .identity))
            }
        }
    }
    
    // MARK: - Subviews
    
    private var orbView: some View {
        Circle()
            .fill(.ultraThinMaterial)
            .frame(width: 200, height: 200)
            .overlay(Circle().stroke(.white.opacity(0.2)))
            .shadow(radius: 20)
    }

    private var backgroundLayer: some View {
        MeshGradient(width: 3, height: 3, points: [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5], [0.5, 0.5], [1, 0.5],
            [0, 1], [0.5, 1], [1, 1]
        ], colors: [
            viewModel.currentMood.colors[0], viewModel.currentMood.colors[1], viewModel.currentMood.colors[0],
            viewModel.currentMood.colors[1], viewModel.currentMood.colors[2], viewModel.currentMood.colors[1],
            viewModel.currentMood.colors[2], viewModel.currentMood.colors[0], viewModel.currentMood.colors[2]
        ])
        .ignoresSafeArea()
        .blur(radius: 40)
    }
    

    private var detailCardView: some View {
        VStack(alignment: .leading, spacing: 25) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Environment Analysis")
                        .font(.system(.title3, design: .rounded)).bold()
                    Text("Real-time decibel tracking")
                        .font(.caption).opacity(0.6)
                }
                Spacer()
                Button(action: { withAnimation(.spring()) { viewModel.showDetails = false } }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            
            // The Live Chart
            Chart(viewModel.noiseHistory) { entry in
                // Line for the top edge
                LineMark(
                    x: .value("Time", entry.timestamp),
                    y: .value("Level", entry.level)
                )
                .interpolationMethod(.catmullRom) // Makes the line wavy/organic
                .foregroundStyle(.white)
                
                // Area for the "Liquid" fill
                AreaMark(
                    x: .value("Time", entry.timestamp),
                    y: .value("Level", entry.level)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    .linearGradient(
                        colors: [.white.opacity(0.4), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .frame(height: 200)
            .chartYScale(domain: 0...1) // Keep scale consistent
            .chartXAxis(.hidden) // Hide labels for a cleaner "2026" look
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(.white.opacity(0.1))
                    AxisValueLabel().foregroundStyle(.white.opacity(0.5))
                }
            }
            .animation(.default, value: viewModel.noiseHistory)

            Spacer()
            Button(action: {
                // Call the method directly on the instance, not via a binding
                Task { @MainActor in
                    if let image = viewModel.generateShareImage() {
                        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                        
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            rootVC.present(activityVC, animated: true)
                        }
                    }
                }
            }) {
                        Label("Share My Aura", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.2))
                            .cornerRadius(15)
                    }
            
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(40)
        .padding()
    }
    
}

#Preview {
    MainAuraView()
}
