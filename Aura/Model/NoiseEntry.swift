//
//  NoiseEntry.swift
//  Aura
//
//  Created by Jency on 10/02/26.
//

import Foundation

struct NoiseEntry: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let level: Double
}
