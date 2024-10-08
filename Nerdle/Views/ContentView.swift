import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var mainViewModel = MainViewModel()
    @StateObject var gameViewModel = GameViewModel()

    var body: some View {
        HStack(spacing: 20) {
            GameView(viewModel: gameViewModel)
                .modelContext(modelContext)
            SettingsView(viewModel: mainViewModel)
                .modelContext(modelContext)
        }
        .onAppear {
            mainViewModel.gameViewModel = gameViewModel
            gameViewModel.setupForGame(Game(hiddenEquation: Equation.generate(length: 8)!))
        }
    }
}

#Preview {
    ContentView()
}
