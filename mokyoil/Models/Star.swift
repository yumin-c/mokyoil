//
//  Star.swift
//  mokyoil
//
//  Created by Yumin on 6/10/25.
//

import Foundation

struct Star: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let ra: Double
    let dec: Double
}
