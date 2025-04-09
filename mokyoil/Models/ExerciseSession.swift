// MotionManager.swift
import Foundation
import CoreMotion
import Combine
import simd


// UIDevice+Vibration.swift
import UIKit
import AudioToolbox

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}


// IdealDirection.swift
import Foundation
import simd
import CoreMotion

func rotationMatrixFromEuler(yaw: Double, pitch: Double, roll: Double) -> CMRotationMatrix {
    let cy = cos(yaw)
    let sy = sin(yaw)
    let cp = cos(pitch)
    let sp = sin(pitch)
    let cr = cos(roll)
    let sr = sin(roll)

    let m11 = cy * cp
    let m12 = cy * sp * sr - sy * cr
    let m13 = cy * sp * cr + sy * sr

    let m21 = sy * cp
    let m22 = sy * sp * sr + cy * cr
    let m23 = sy * sp * cr - cy * sr

    let m31 = -sp
    let m32 = cp * sr
    let m33 = cp * cr

    return CMRotationMatrix(
        m11: m11, m12: m12, m13: m13,
        m21: m21, m22: m22, m23: m23,
        m31: m31, m32: m32, m33: m33
    )
}

func idealDirectionVector(at time: TimeInterval) -> SIMD3<Double> {
    let yaw = sin(time) * .pi / 6
    let pitch = cos(time) * .pi / 9
    let roll = sin(time + .pi / 4) * .pi / 12

    let matrix = rotationMatrixFromEuler(yaw: yaw, pitch: pitch, roll: roll)
    return SIMD3(matrix.m31, matrix.m32, matrix.m33)
}


// ExerciseSession.swift
import Foundation
import SwiftUI
import Combine
import simd

class ExerciseSession: ObservableObject {
    @Published var motionManager = MotionManager()
    @Published var roundCount: Int = 0
    @Published var pathPoints: [CGPoint] = []
    @Published var score: Int = 0
    @Published var isRunning: Bool = false
    @Published var remainingTime: Int = 60

    let goalCount = 10
    let sessionLength = 60

    private var timer: Timer?
    private var lastVector: CGVector?
    private var accumulatedAngle: Double = 0
    private var lastVibrationTime: TimeInterval = 0
    private let vibrationCooldown: TimeInterval = 1.5
    private let errorThreshold: Double = .pi / 6

    var statusText: String {
        if !isRunning {
            return "운동을 시작하세요"
        } else if roundCount >= goalCount {
            return "완료! 점수: \(score)점"
        } else {
            return "운동 중..."
        }
    }

    func start() {
        reset()
        isRunning = true
        remainingTime = sessionLength
        motionManager.startUpdates()

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.remainingTime > 0 {
                self.remainingTime -= 1 / 20
            } else {
                self.stop()
                return
            }

            self.trackPath()
            self.detectFullRotation()
        }
    }

    func stop() {
        timer?.invalidate()
        motionManager.stopUpdates()
        isRunning = false
        calculateScore()
    }

    func reset() {
        stop()
        roundCount = 0
        accumulatedAngle = 0
        lastVector = nil
        pathPoints = []
        score = 0
    }

    func trackPath() {
        let forward = motionManager.directionVector
        let x = CGFloat(forward.x)
        let y = CGFloat(forward.y)
        let norm = sqrt(x*x + y*y)
        guard norm > 0.01 else { return }

        let point = CGPoint(x: x / norm * 100, y: y / norm * 100)
        pathPoints.append(point)
        if pathPoints.count > 300 {
            pathPoints.removeFirst()
        }

        // 오차 계산 + 진동
        let now = Date().timeIntervalSinceReferenceDate
        let ideal = idealDirectionVector(at: now)
        let dot = simd_dot(forward, ideal)
        let error = acos(min(max(dot, -1), 1))

        if error > errorThreshold,
           now - lastVibrationTime > vibrationCooldown {
            UIDevice.vibrate()
            lastVibrationTime = now
        }
    }

    func detectFullRotation() {
        let forward = motionManager.directionVector
        let x = CGFloat(forward.x)
        let y = CGFloat(forward.y)
        let norm = sqrt(x*x + y*y)
        guard norm > 0.01 else { return }

        let currentVector = CGVector(dx: x / norm, dy: y / norm)

        if let last = lastVector {
            let dot = max(min(last.dx * currentVector.dx + last.dy * currentVector.dy, 1), -1)
            let cross = last.dx * currentVector.dy - last.dy * currentVector.dx
            let angle = atan2(cross, dot)

            accumulatedAngle += angle

            if abs(accumulatedAngle) >= 2 * .pi {
                roundCount += 1
                accumulatedAngle = 0
            }
        }

        lastVector = currentVector
    }

    func calculateScore() {
        let xs = pathPoints.map { $0.x }
        let ys = pathPoints.map { $0.y }

        let xSpread = (xs.max() ?? 0) - (xs.min() ?? 0)
        let ySpread = (ys.max() ?? 0) - (ys.min() ?? 0)

        let areaScore = min(Int((xSpread + ySpread)), 200) / 2
        let countScore = roundCount * 5

        score = areaScore + countScore
    }
}
