// SoundSessionManager.swift
import Foundation
import Combine

class SoundSessionManager: ObservableObject {
    @Published var currentTargetYaw: Double = 0.0
    @Published var currentTargetPitch: Double = 0.0
    @Published var score: Int = 0
    @Published var reactionTimes: [Double] = []
    @Published var isRunning = false
    @Published var timeRemaining: Int = 60

    private var timer: Timer?
    private var pingTimer: Timer?
    private var soundStartTime: Date?
    private var cancellables = Set<AnyCancellable>()

    private let motionManager: MotionManager
    private let soundEngine: SpatialSoundEngine

    init(motionManager: MotionManager, soundEngine: SpatialSoundEngine) {
        self.motionManager = motionManager
        self.soundEngine = soundEngine
    }

    func startSession() {
        score = 0
        reactionTimes = []
        timeRemaining = 60
        isRunning = true
        motionManager.calibrateReference()
        motionManager.startUpdates()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { return }
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 {
                self.endSession()
            }
        }

        playNextPing()

        // 실시간 도달 체크
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] checkTimer in
            guard let self = self, self.isRunning else {
                checkTimer.invalidate()
                return
            }
            self.checkIfTargetReached()
        }
    }

    private func playNextPing() {
        guard isRunning else { return }

        currentTargetYaw = Double.random(in: -95...95)
        currentTargetPitch = Double.random(in: -45...45)
        
        
        soundEngine.playPing(atYaw: currentTargetYaw, pitch: currentTargetPitch)
        soundStartTime = Date()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if self.timeRemaining > 0 {
                self.playNextPing()
            }
        }
    }

    private func checkIfTargetReached() {
        let angle = motionManager.angularDistance(to: currentTargetYaw, targetPitch: currentTargetPitch)

        if angle < 5.0, let soundTime = soundStartTime {
            let delay = Date().timeIntervalSince(soundTime)
            let point = max(0, Int(100 - delay * 100)) // 1초 이내 = 최대점수 100
            score += point
            reactionTimes.append(delay)
            soundStartTime = nil // 다시 반응 방지
        }
    }

    func endSession() {
        isRunning = false
        timer?.invalidate()
        motionManager.stopUpdates()
        soundEngine.stop()
    }
}
