import Foundation
import SwiftUI

class ExerciseSession: ObservableObject {
    enum Difficulty: String, CaseIterable, Identifiable {
        case easy, medium, hard
        var id: String { rawValue }

        var asteroidSpeed: CGFloat {
            switch self {
            case .easy: return 1.5
            case .medium: return 2.5
            case .hard: return 4.0
            }
        }

        var spawnInterval: TimeInterval {
            switch self {
            case .easy: return 2.0
            case .medium: return 1.5
            case .hard: return 1.0
            }
        }
    }

    @Published var motionManager = MotionManager()
    @Published var spaceshipPosition: CGPoint = .zero
    @Published var asteroids: [Asteroid] = []
    @Published var score: Int = 0
    @Published var bestScores: [Difficulty: Int] = [.easy: 0, .medium: 0, .hard: 0]
    @Published var timeRemaining: Int = 60
    @Published var isRunning = false
    @Published var showResult = false

    var difficulty: Difficulty = .medium

    private var timer: Timer?
    private var asteroidTimer: Timer?
    private var angle: CGFloat = 0.0
    private var radius: CGFloat = 100.0
    private var lastYaw: Double = 0.0

    func startGame(difficulty: Difficulty) {
        self.difficulty = difficulty
        reset()
        isRunning = true
        motionManager.startUpdates()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 {
                self.endGame()
            }
        }

        asteroidTimer = Timer.scheduledTimer(withTimeInterval: difficulty.spawnInterval, repeats: true) { [weak self] _ in
            self?.spawnAsteroid()
        }

        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] t in
            guard let self = self, self.isRunning else { t.invalidate(); return }
            self.updateSpaceship()
            self.moveAsteroids()
            self.checkCollisions()
        }
    }

    func reset() {
        timeRemaining = 60
        score = 0
        asteroids = []
        spaceshipPosition = .zero
        showResult = false
        angle = 0.0
        radius = 100.0
        lastYaw = motionManager.yaw
    }

    func endGame() {
        isRunning = false
        motionManager.stopUpdates()
        timer?.invalidate()
        asteroidTimer?.invalidate()
        showResult = true

        if score > (bestScores[difficulty] ?? 0) {
            bestScores[difficulty] = score
        }
    }

    func updateSpaceship() {
        let yaw = motionManager.yaw
        let delta = yaw - lastYaw
        if delta > 0.5 {
            radius += 1
        } else if delta < -0.5 {
            radius -= 1
        }
        radius = min(max(radius, 60), 180)
        lastYaw = yaw

        angle += 0.05
        let centerX: CGFloat = 180
        let centerY: CGFloat = 300
        let x = centerX + cos(angle) * radius
        let y = centerY + sin(angle) * radius
        spaceshipPosition = CGPoint(x: x, y: y)
    }

    func spawnAsteroid() {
        let x = CGFloat.random(in: 40...320)
        let asteroid = Asteroid(position: CGPoint(x: x, y: -30), speed: difficulty.asteroidSpeed)
        asteroids.append(asteroid)
    }

    func moveAsteroids() {
        for i in 0..<asteroids.count {
            asteroids[i].position.y += asteroids[i].speed
        }
        asteroids.removeAll { $0.position.y > 700 }
    }

    func checkCollisions() {
        for asteroid in asteroids {
            let dx = asteroid.position.x - spaceshipPosition.x
            let dy = asteroid.position.y - spaceshipPosition.y
            let distance = sqrt(dx*dx + dy*dy)
            if distance < 30 {
                score += 1
                if let index = asteroids.firstIndex(where: { $0.id == asteroid.id }) {
                    asteroids.remove(at: index)
                }
                break
            }
        }
    }
}
