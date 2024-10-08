import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: MainViewModel
    @Query(sort: \Game.id, order: .forward, animation: .smooth)
    var games: [Game]
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Button {
                    viewModel.selectGameModeAndPresentGameSizeMenu(.dailyChallenge)
                } label: {
                    Text("Daily Challenge")
                        .font(.system(size: 20))
                        .frame(width: 200, height: 70)
                }
                .buttonStyle(BlueButtonStyle())
                Button {
                    viewModel.selectGameModeAndPresentGameSizeMenu(.trainMode)
                } label: {
                    Text("Train Mode")
                        .font(.system(size: 20))
                        .frame(width: 200, height: 70)
                }
                .buttonStyle(BlueButtonStyle())
            }
            Spacer()
        }
        .overlay {
            gameHistory
        }
        .overlay {
            gameSizeMenu
        }
    }
    
    var gameHistory: some View {
        VStack(spacing: 10) {
            ForEach(games) { game in
                gameResultView(game)
            }
        }
    }
    var gameSizeMenu: some View {
        SwiftUI.Group {
            if viewModel.isMenuSelected {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.gray)
                    .frame(width: 300, height: 400)
                    .overlay {
                        VStack(spacing: 10) {
                            gameSizeButton(title: "Classic", gameSize: .classic)
                            gameSizeButton(title: "Mini", gameSize: .mini)
                            gameSizeButton(title: "Micro", gameSize: .micro)
                        }
                    }
            }
        }
    }
    
    func gameResultView(_ game: Game) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(
                game.isGameOver ? (game.isGameWon ? Color(red: 0.2, green: 0.9, blue: 0.4)
                                   : Color(red: 0.965, green: 0.812, blue: 0.827)) : .gray
            )
            .frame(width: 300, height: 100)
            .overlay {
                HStack(spacing: 5) {
                    Text("\(game.currentAttempt)/\(game.maximumAttempts)")
                        .font(.system(size: 15))
                        .font(.system(size: 15))
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .onTapGesture {
                viewModel.gameViewModel?.setupForGame(game)
            }
    }
    
    
    func gameSizeButton(title: String, gameSize: GameSize) -> some View {
            Button {
                withAnimation(.easeInOut) {
                    viewModel.selectGameSize(gameSize)
                }
            } label: {
                Text(title)
                    .font(.system(size: 20))
                    .frame(width: 170, height: 70)
            }
            .buttonStyle(BlueButtonStyle())
    }
}
