// MotionManager.swift
import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let manager = CMHeadphoneMotionManager()
    @Published var yaw: Double = 0.0
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var isAvailable: Bool = false

    private(set) var referenceYaw: Double = 0.0
    private(set) var referencePitch: Double = 0.0

    func startUpdates() {
        isAvailable = manager.isDeviceMotionAvailable
        guard isAvailable else { return }

        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self = self, let motion = motion else { return }

            self.yaw = motion.attitude.yaw * 180 / .pi
            self.pitch = motion.attitude.pitch * 180 / .pi
            self.roll = motion.attitude.roll * 180 / .pi
        }
    }

    func stopUpdates() {
        manager.stopDeviceMotionUpdates()
    }

    func calibrateReference() {
        referenceYaw = yaw
        referencePitch = pitch
    }

    func relativeYaw() -> Double {
        var delta = yaw - referenceYaw
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }
        return delta
    }

    func relativePitch() -> Double {
        return pitch - referencePitch
    }

    func angularDistance(to targetYaw: Double, targetPitch: Double) -> Double {
        let dyaw = relativeYaw() - targetYaw
        let dpitch = relativePitch() - targetPitch
        return sqrt(dyaw * dyaw + dpitch * dpitch)
    }
}
