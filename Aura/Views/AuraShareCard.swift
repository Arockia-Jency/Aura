//
//  AuraShareCard.swift
//  Aura
//
//  Created by Jency on 10/02/26.
//

import SwiftUI

struct AuraShareCard: View {
    let mood: AuraMood
    let noiseLevel: Float
    
    var body: some View {
        VStack(spacing: 20) {
            Text("MY CURRENT AURA")
                .font(.system(size: 12, weight: .black))
                .tracking(5)
            
            // The signature orb
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 150, height: 150)
                .overlay(Circle().stroke(.white.opacity(0.5)))
            
            Text(mood == .calm ? "Peaceful" : "Vibrant")
                .font(.system(size: 32, weight: .thin, design: .rounded))
            
            Text("Noise Intensity: \(Int(noiseLevel * 100))%")
                .font(.caption)
        }
        .padding(40)
        .frame(width: 400, height: 400)
        .background(
            MeshGradient(width: 3, height: 3, points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ], colors: mood.colors + mood.colors + mood.colors) // Repeating colors for a rich mesh
        )
        .foregroundColor(.white)
    }
}


