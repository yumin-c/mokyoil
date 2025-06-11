//
//  ObservationView.swift
//  mokyoil
//
//  Created by Yumin on 6/10/25.
//

import SwiftUI

struct ObservationView: View {
    @EnvironmentObject var motionManager: MotionManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                if let delta = motionManager.directionDelta {
                    ArrowView(deltaYaw: delta.0, deltaPitch: delta.1)
                        .frame(width: 200, height: 200)
                } else {
                    Text("방향을 계산 중입니다...")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                motionManager.startTracking()
            }
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
                motionManager.speakDirection()
            }
        }
    }
}
