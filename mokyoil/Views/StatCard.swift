import SwiftUI

struct StatCard: View {
    var title: String
    var value: String
    var graph: [Bool] // 단순 점 상태 표현

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.green)

            HStack {
                Text(value)
                    .font(.title2)
                    .fontWeight(.medium)

                Spacer()

                HStack(spacing: 4) {
                    ForEach(graph, id: \.self) { filled in
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundColor(filled ? .green : .gray.opacity(0.4))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
