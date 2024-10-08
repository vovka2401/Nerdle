import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var game = Game.defaultGame
    @Published var selectedTile: Tile?
    @Published var toast: Toast?
    
    func setupForGame(_ game: Game) {
        self.game = game
        selectedTile = game.currentEquation.tiles.first
    }
    
    func handleOnPressKeyEvent(key: KeyEquivalent) {
        let symbolKeys = Symbol.allCases.map({ KeyEquivalent(Character($0.rawValue)) })
        let deleteKey = KeyEquivalent("\u{7F}")
        switch key {
        case .return: guess()
        case deleteKey: delete()
        case .leftArrow: selectPreviousTile()
        case .rightArrow: selectNextTile()
        case _ where symbolKeys.contains(key):
            if let symbol = Symbol(rawValue: String(key.character)) {
                selectSymbol(symbol)
            }
        default: break
        }
    }

    func guess() {
        guard game.currentEquation.isValid() else {
            showToast(Toast(message: "That guess does not compute"))
            return
        }
        for symbol in Symbol.allCases {
            var availableSymbolsCount = game.hiddenEquation.tiles.compactMap(\.symbol).filter({ $0 == symbol }).count
            for i in 0 ..< game.hiddenEquation.tiles.count {
                if symbol == game.currentEquation.tiles[i].symbol, symbol == game.hiddenEquation.tiles[i].symbol {
                    game.equations[game.currentAttempt].tiles[i].color = .rightPositionSymbol
                    availableSymbolsCount -= 1
                }
            }
            for i in 0 ..< game.hiddenEquation.tiles.count {
                if symbol == game.currentEquation.tiles[i].symbol, symbol != game.hiddenEquation.tiles[i].symbol {
                    if availableSymbolsCount > 0 {
                        game.equations[game.currentAttempt].tiles[i].color = .wrongPositionSymbol
                    } else {
                        game.equations[game.currentAttempt].tiles[i].color = .absentSymbol
                    }
                    availableSymbolsCount -= 1
                    updateBottomTileColor(tile: game.equations[game.currentAttempt].tiles[i])
                }
                updateBottomTileColor(tile: game.equations[game.currentAttempt].tiles[i])
            }
        }
        if game.currentEquation.tiles.map(\.color).filter({ $0 == Color.rightPositionSymbol }).count == game.hiddenEquation.length {
            game.isGameOver = true
            game.isGameWon = true
            
        } else if game.currentAttempt == game.maximumAttempts - 1 {
            game.isGameOver = true
        } else {
            game.currentAttempt += 1
            selectTile(game.equations[game.currentAttempt].tiles[0])
        }
    }
    
    func delete() {
        selectSymbol(nil) {
            self.selectPreviousTile()
        }
    }
    
    func selectSymbol(_ symbol: Symbol) {
        selectSymbol(symbol) {
            self.selectNextTile()
        }
    }
    
    func selectTile(_ tile: Tile) {
        selectedTile = tile
    }
    
    func getResultToShare() -> String {
        var message = "game (\(game.currentAttempt)/\(game.maximumAttempts))"
        for equation in game.equations where equation.isValid() {
            message.append("\n")
            for tile in equation.tiles {
                switch tile.color {
                case .rightPositionSymbol:
                    message.append("🟩")
                case .wrongPositionSymbol:
                    message.append("🟪")
                case .absentSymbol:
                    message.append("⬛")
                default: continue
                }
            }
        }
        return message
    }
    
    func restartGame() {
        let game = Game(hiddenEquation: game.hiddenEquation)
        setupForGame(game)
    }
    
    func replayLastGuess() {
        game.isGameOver = false
        game.equations[game.equations.count - 1].tiles = game.equations[game.equations.count - 1].tiles.map({ _ in Tile() })
        selectedTile = game.currentEquation.tiles.first
    }
    
    private func updateBottomTileColor(tile: Tile) {
        guard let symbol = tile.symbol else { return }
        let color = tile.color
        let colorOrder = [Color.unusedSymbol, .absentSymbol, .wrongPositionSymbol, .rightPositionSymbol]
        if let index = game.bottomNumberTiles.firstIndex(where: { $0.symbol == symbol }) {
            if let symbolColorIndex = colorOrder.firstIndex(of: game.bottomNumberTiles[index].color),
               let colorIndex = colorOrder.firstIndex(of: color),
            symbolColorIndex < colorIndex {
                game.bottomNumberTiles[index].color = color
            }
        }
        if let index = game.bottomOperatorTiles.firstIndex(where: { $0.symbol == symbol }) {
            if let symbolColorIndex = colorOrder.firstIndex(of: game.bottomOperatorTiles[index].color),
               let colorIndex = colorOrder.firstIndex(of: color),
            symbolColorIndex < colorIndex {
                game.bottomOperatorTiles[index].color = color
            }
        }
    }

    private func selectPreviousTile() {
        guard let selectedTile, let indexOfTile = game.equations[game.currentAttempt].tiles.firstIndex(of: selectedTile), indexOfTile > 0 else { return }
        let indexOfPreviousTile = indexOfTile - 1
        self.selectedTile = game.equations[game.currentAttempt].tiles[indexOfPreviousTile]
    }
    
    private func selectNextTile() {
        guard let selectedTile, let indexOfTile = game.equations[game.currentAttempt].tiles.firstIndex(of: selectedTile), indexOfTile + 1 < game.hiddenEquation.length else { return }
        let indexOfNextTile = indexOfTile + 1
        self.selectedTile = game.equations[game.currentAttempt].tiles[indexOfNextTile]
    }
    
    private func selectSymbol(_ symbol: Symbol?, completion: (() -> Void)? = nil) {
        selectedTile?.symbol = symbol
        guard let selectedTile, let indexOfTile = game.equations[game.currentAttempt].tiles.firstIndex(of: selectedTile) else { return }
        game.equations[game.currentAttempt].tiles[indexOfTile].symbol = symbol
        completion?()
    }
}

// MARK: - Toast

extension GameViewModel {
    func showToast(_ toast: Toast) {
        self.toast = toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.hideToast(toast)
        }
    }

    func hideToast(_ toast: Toast) {
        guard let currentToast = self.toast, toast.id == currentToast.id else { return }
        hideToast()
    }

    func hideToast() {
        guard toast != nil else { return }
        toast = nil
    }
}
