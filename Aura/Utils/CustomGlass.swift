//
//  CustomGlass.swift
//  Aura
//
//  Created by Jency on 10/02/26.
//

import Foundation
import SwiftUI

struct GlassElement: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.3), lineWidth: 0.5) // The "Edge" reflection
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 10)
    }
}

extension View {
    func auraGlassStyle() -> some View {
        modifier(GlassElement())
    }
}
