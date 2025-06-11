//
//  ArrowView.swift
//  mokyoil
//
//  Created by Yumin on 6/10/25.
//

import SwiftUI

struct ArrowView: View {
    let deltaYaw: Double
    let deltaPitch: Double

    var body: some View {
        let isWithinThreshold = deltaYaw >= -1 && deltaYaw <= 1 && deltaPitch >= -1 && deltaPitch <= 1
        let displayColor: Color = isWithinThreshold ? .white : .red

        VStack {
            Text("Yaw: \(Int(deltaYaw))°, Pitch: \(Int(deltaPitch))°")
                .foregroundColor(displayColor)
            Image(systemName: "arrow.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(.degrees(-deltaYaw))
                .foregroundColor(displayColor)
        }
    }
}
