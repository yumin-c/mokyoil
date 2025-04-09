import Foundation
import CoreMotion
import Combine
import simd

class MotionManager: ObservableObject {
    private let manager = CMHeadphoneMotionManager()
    private var updateInterval: TimeInterval = 1.0 / 60.0

    @Published var directionVector: SIMD3<Double> = SIMD3<Double>(0, 0, -1)

    func startUpdates() {
        guard manager.isDeviceMotionAvailable else {
            print("❗️AirPods 모션 데이터 사용 불가")
            return
        }

        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else {
                if let error = error {
                    print("Motion error: \(error.localizedDescription)")
                }
                return
            }

            let rotationMatrix = motion.attitude.rotationMatrix
            let forward = SIMD3<Double>(rotationMatrix.m31, rotationMatrix.m32, rotationMatrix.m33)
            self.directionVector = forward
        }
    }

    func stopUpdates() {
        manager.stopDeviceMotionUpdates()
    }
}
