//
//  AuraMood.swift
//  Aura
//
//  Created by Jency on 10/02/26.
//

import Foundation
import SwiftUI

enum AuraMood {
    case calm, energetic, stressed
    
    var colors: [Color] {
        switch self {
        case .calm: return [.blue, .teal, .indigo]
        case .energetic: return [.orange, .yellow, .red]
        case .stressed: return [.purple, .black, .indigo]
        }
    }
}
