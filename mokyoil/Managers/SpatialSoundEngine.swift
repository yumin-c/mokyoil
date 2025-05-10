// SpatialSoundEngine.swift
// 02:24, May 11 2025 -> 지금 오디오 방향성은 되는데, spatial audio 기능 통합해서 고정된 방향에서 들리도록 해야함

import Foundation
import AVFoundation

class SpatialSoundEngine: ObservableObject {
    private let engine = AVAudioEngine()
    private let environment = AVAudioEnvironmentNode()
    private let player = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    private var isPlaying = false

    init() {
        // AVAudioSession 설정 (선택사항이지만 권장)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth])

        engine.attach(environment)
        engine.attach(player)

        // 환경 노드를 메인 믹서에 연결
        let stereoFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
        engine.connect(environment, to: engine.mainMixerNode, format: stereoFormat)

        // 오디오 파일 로딩
        if let url = Bundle.main.url(forResource: "find-my-sound", withExtension: "mp3") {
            do {
                audioFile = try AVAudioFile(forReading: url)

                // mono 형식으로 플레이어 노드 연결
                let monoFormat = AVAudioFormat(standardFormatWithSampleRate: audioFile!.processingFormat.sampleRate, channels: 1)
                engine.connect(player, to: environment, format: monoFormat)

            } catch {
                print("❗️오디오 파일 로딩 실패: \(error.localizedDescription)")
            }
        }

        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.renderingAlgorithm = .HRTFHQ

        do {
            try engine.start()
        } catch {
            print("❗️오디오 엔진 시작 실패: \(error.localizedDescription)")
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

        // 방향 설정
        player.position = position
        player.pointSourceInHeadMode = .mono
        player.renderingAlgorithm = .HRTFHQ

        player.stop()
        player.scheduleFile(audioFile, at: nil, completionHandler: { [weak self] in
            self?.isPlaying = false
        })
        player.play()
        isPlaying = true
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





