import SwiftUI

struct ExerciseView: View {
    @StateObject private var session = ExerciseSession()

    var body: some View {
        VStack {
            Text(session.statusText)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 40)

            Spacer()

            ZStack {
                // 💠 이상 경로 (ideal path)
                Path { path in
                    let now = Date().timeIntervalSinceReferenceDate
                    let points = stride(from: now - 2.0, through: now, by: 0.05).map { t in
                        let ideal = idealDirectionVector(at: t)
                        let x = CGFloat(ideal.x)
                        let y = CGFloat(ideal.y)
                        let norm = sqrt(x*x + y*y)
                        return CGPoint(x: x / norm * 100, y: y / norm * 100)
                    }

                    guard let first = points.first else { return }
                    path.move(to: convertToCenter(first))
                    for point in points {
                        path.addLine(to: convertToCenter(point))
                    }
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundColor(.blue.opacity(0.4))

                // 🟢 실제 경로 (센서 기반)
                Path { path in
                    guard let first = session.pathPoints.first else { return }
                    path.move(to: convertToCenter(first))
                    for point in session.pathPoints {
                        path.addLine(to: convertToCenter(point))
                    }
                }
                .stroke(Color.green, lineWidth: 2)

                // 🔵 현재 위치
                if let last = session.pathPoints.last {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .position(convertToCenter(last))
                }
            }
            .frame(width: 240, height: 240)

            Spacer()

            VStack(spacing: 8) {
                Text("⏱ 남은 시간: \(session.remainingTime)s")
                Text("🔄 회전 수: \(session.roundCount)/\(session.goalCount)")
                Text("📈 유연성 점수: \(session.score)점")

                Button(action: {
                    session.start()
                }) {
                    Text(session.isRunning ? "운동 중..." : "운동 시작")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(session.isRunning ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(session.isRunning)
            }
            .padding()
        }
        .padding()
    }

    // 중심 정렬용 좌표 보정
    private func convertToCenter(_ point: CGPoint) -> CGPoint {
        let centerX: CGFloat = 120
        let centerY: CGFloat = 120
        return CGPoint(x: centerX + point.x, y: centerY - point.y)
    }
}

#Preview {
    ExerciseView()
}
