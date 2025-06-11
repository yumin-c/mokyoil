//
//  StarSelectionView.swift
//  mokyoil
//
//  Created by Yumin on 6/10/25.
//

import SwiftUI

struct StarSelectionView: View {
    @EnvironmentObject var motionManager: MotionManager

    let stars = [
        Star(name: "북극성", ra: 2.5303, dec: 89.2641),
        Star(name: "시리우스", ra: 6.7525, dec: -16.7161),
        Star(name: "베텔게우스", ra: 5.9195, dec: 7.4071)
    ]

    var body: some View {
        List(stars) { star in
            Button(star.name) {
                motionManager.setTarget(star: star)
            }
            .foregroundColor(.white)
        }
        .background(Color.black)
        .listStyle(PlainListStyle())
        .onChange(of: motionManager.targetStar) { _ in
            if motionManager.targetStar != nil {
                motionManager.startTracking()
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { motionManager.targetStar != nil },
            set: { _ in }
        )) {
            ObservationView()
                .environmentObject(motionManager)
        }
    }
}
