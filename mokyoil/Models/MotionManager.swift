//
//  MotionData.swift
//  mokyoil
//
//  Created by Yumin on 6/10/25.
//

import Foundation
import CoreMotion
import AVFoundation
import CoreLocation

class MotionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let motionManager = CMHeadphoneMotionManager()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let locationManager = CLLocationManager()

    @Published var targetStar: Star?
    @Published var directionDelta: (Double, Double)?

    private var zeroYaw: Double = 0
    private var zeroPitch: Double = 0
    private var currentYaw: Double = 0
    private var currentPitch: Double = 0
    private var latitude: Double?
    private var longitude: Double?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startMotionUpdates()
    }

    func calibrate() {
        zeroYaw = currentYaw
        zeroPitch = currentPitch
    }

    func setTarget(star: Star) {
        targetStar = star
    }

    func startTracking() {
        guard let star = targetStar, let lat = latitude, let lon = longitude else {
            print("Tracking failed: missing star or location")
            return
        }
        let now = Date()
        let altAz = AstronomyCalculator.calculateAltAz(for: star, date: now, lat: lat, lon: lon)
        let deltaYaw = altAz.azimuth - (currentYaw - zeroYaw)
        let deltaPitch = altAz.altitude - (currentPitch - zeroPitch)
        directionDelta = (deltaYaw, deltaPitch)
    }

    func speakDirection() {
        guard let delta = directionDelta else { return }
        let yawText = delta.0 < 0 ? "오른쪽으로 \(Int(abs(delta.0)))도" : "왼쪽으로 \(Int(abs(delta.0)))도"
        let pitchText = delta.1 < 0 ? "위로 \(Int(abs(delta.1)))도" : "아래로 \(Int(abs(delta.1)))도"
        let message = "\(yawText), \(pitchText) 고개를 움직여 주세요."
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        speechSynthesizer.speak(utterance)
    }

    private func startMotionUpdates() {
//        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let attitude = motion?.attitude else { return }
            self?.currentYaw = attitude.yaw * 180 / .pi
            self?.currentPitch = attitude.pitch * 180 / .pi
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
    }
}
