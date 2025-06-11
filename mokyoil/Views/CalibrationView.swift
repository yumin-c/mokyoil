//
//  CalibrationView.swift
//  mokyoil
//
//  Created by Yumin on 6/10/25.
//

import SwiftUI
import CoreLocation

struct CalibrationView: View {
    @StateObject private var motionManager = MotionManager()
    @StateObject private var compassHeading = CompassHeading()
    @State private var isCalibrated = false

    var isFacingNorth: Bool {
        abs(compassHeading.degrees - 0) <= 3 || abs(compassHeading.degrees - 360) <= 3
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("정면 북쪽을 바라보세요")
                .foregroundColor(.white)
                .font(.title)
            
            Text("계산을 정렬하기 위해 iPhone을 지면과 수직으로 북쪽을 향해 들고 얼굴 높이에서 정면으로 응시하세요")
                .foregroundColor(.white)

            Text("현재 방향: \(Int(compassHeading.degrees))°N")
                .foregroundColor(.white)

            Button("영점 설정") {
                motionManager.calibrate()
                isCalibrated = true
//                print("Current pitch: \(motionManager.currentPitch)°")
            }
            .padding()
            .background(isFacingNorth ? Color.white : Color.gray)
            .foregroundColor(.black)
            .cornerRadius(10)
            .disabled(!isFacingNorth)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onAppear {
            compassHeading.startUpdatingHeading()
        }
        .onDisappear {
            compassHeading.stopUpdatingHeading()
        }
        .fullScreenCover(isPresented: $isCalibrated) {
            StarSelectionView()
                .environmentObject(motionManager)
        }
    }
}
