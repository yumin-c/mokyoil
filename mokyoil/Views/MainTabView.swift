import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house")
                }

            ExerciseView()
                .tabItem {
                    Label("운동", systemImage: "figure.walk.circle")
                }
        }
    }
}

#Preview {
    MainTabView()
}
