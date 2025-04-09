import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                StatCard(title: "최근 목 운동", value: "4회", graph: SampleGraph.dots)
                StatCard(title: "목 유연성", value: "95점", graph: SampleGraph.dots)
                StatCard(title: "거북목 위험", value: "중간", graph: SampleGraph.dots)
                
                Spacer()
            }
            .padding()
            .navigationTitle("mokyoil")
        }
    }
}

#Preview {
    HomeView()
}
