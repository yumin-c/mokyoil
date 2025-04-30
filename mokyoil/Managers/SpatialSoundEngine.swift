// SpatialSoundEngine.swift
import Foundation
import AVFoundation

class SpatialSoundEngine: ObservableObject {
    private let engine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()
    private let player = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    private var isPlaying = false

    init() {
        engine.attach(environment)
        engine.attach(player)

        engine.connect(player, to: environment, format: nil)
        engine.connect(environment, to: engine.mainMixerNode, format: nil)

        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)

        do {
            try engine.start()
        } catch {
            print("❗️오디오 엔진 시작 실패: \(error.localizedDescription)")
        }

        if let url = Bundle.main.url(forResource: "ping", withExtension: "mp3") {
            do {
                audioFile = try AVAudioFile(forReading: url)
            } catch {
                print("❗️기본 사운드 로딩 실패: \(error.localizedDescription)")
            }
        }
    }

    func playPing(atYaw yaw: Double, pitch: Double) {
        guard let audioFile else { return }

        let radiansYaw = yaw * .pi / 180
        let radiansPitch = pitch * .pi / 180

        let x = 2 * sin(radiansYaw) * cos(radiansPitch)
        let y = 2 * cos(radiansPitch) * cos(radiansYaw)
        let z = 2 * sin(radiansPitch)

        let position = AVAudio3DPoint(x: Float(x), y: Float(y), z: Float(z))
        player.position = position

        if !isPlaying {
            isPlaying = true
            player.scheduleFile(audioFile, at: nil, completionHandler: { [weak self] in
                self?.isPlaying = false
            })
            engine.prepare()
            try? engine.start()
            engine.attach(player)
            player.play()

            // 5초간 반복 재생
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.stop()
            }
        }
    }

    func stop() {
        player.stop()
        isPlaying = false
    }

    func updateListener(yaw: Double, pitch: Double, roll: Double = 0) {
        environment.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: Float(yaw),
            pitch: Float(pitch),
            roll: Float(roll)
        )
    }
}
