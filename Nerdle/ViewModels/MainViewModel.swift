import SwiftUI

class MainViewModel: ObservableObject {
    @Published var selectedGameMode = GameMode.dailyChallenge
    @Published var temporarilySelectedGameMode: GameMode?
    @Published var isMenuSelected = false
    weak var gameViewModel: GameViewModel?
    
    func selectGameModeAndPresentGameSizeMenu(_ mode: GameMode) {
        isMenuSelected = true
        temporarilySelectedGameMode = mode
    }
    
    func dismissGameSizeMenu() {
        isMenuSelected = false
        temporarilySelectedGameMode = nil
    }
    
    func selectGameSize(_ gameSize: GameSize) {
        guard let temporarilySelectedGameMode else { return }
        selectedGameMode = temporarilySelectedGameMode
        dismissGameSizeMenu()
        if selectedGameMode == .trainMode, let equation = Equation.generate(length: gameSize.rawValue) {
            gameViewModel?.setupForGame(Game(hiddenEquation: equation))
        } else {
            let equation = Equation.selectEquationForToday()
            gameViewModel?.setupForGame(Game(hiddenEquation: equation))
        }
    }
    
    func presentGame(gameMode: GameMode, gameSize: GameSize) {
        isMenuSelected = true
    }
}
