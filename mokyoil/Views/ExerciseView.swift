// ExerciseView.swift
import SwiftUI

struct ExerciseView: View {
    @StateObject private var motionManager = MotionManager()
    @StateObject private var soundEngine = SpatialSoundEngine()
    @StateObject private var session: SoundSessionManager

    init() {
        let motion = MotionManager()
        let sound = SpatialSoundEngine()
        _motionManager = StateObject(wrappedValue: motion)
        _soundEngine = StateObject(wrappedValue: sound)
        _session = StateObject(wrappedValue: SoundSessionManager(motionManager: motion, soundEngine: sound))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("🎧 방향 반응 훈련").font(.title)

            Text("남은 시간: \(session.timeRemaining)s")
            Text("점수: \(session.score)")

            VStack(spacing: 4) {
                Text(String(format: "Yaw: %.1f°", motionManager.relativeYaw()))
                Text(String(format: "Pitch: %.1f°", motionManager.relativePitch()))
            }
            .font(.caption)

            if session.isRunning {
                VStack(spacing: 4) {
                    Text("🎯 목표 Yaw: \(Int(session.currentTargetYaw))°")
                    Text("🎯 목표 Pitch: \(Int(session.currentTargetPitch))°")
                }
                .foregroundColor(.orange)
                .font(.headline)
            }

            Spacer()
            
            if session.isRunning {
                Button("🛑 종료하기") {
                    session.endSession()
                }
                .font(.title2)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Button("🚀 시작하기") {
                    session.startSession()
                }
                .font(.title2)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            if !session.isRunning && session.timeRemaining < 60 {
                VStack(spacing: 4) {
                    Text("세션 종료!").font(.title2)
                    Text("총 반응 횟수: \(session.reactionTimes.count)")
                    if let best = session.reactionTimes.min() {
                        Text(String(format: "최고 반응 속도: %.2f초", best))
                    }
                    if let avg = session.reactionTimes.average() {
                        Text(String(format: "평균 반응 속도: %.2f초", avg))
                    }
                }
            }

            Spacer()
        }
        .padding()
    }
}

extension Array where Element == Double {
    func average() -> Double? {
        guard !isEmpty else { return nil }
        let total = reduce(0, +)
        return total / Double(count)
    }
}
