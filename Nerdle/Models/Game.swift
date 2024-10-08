import SwiftUI
import SwiftData

@Model
class Game: Identifiable {
    let id: String
    let hiddenEquation: Equation
    let maximumAttempts = 6
    var equations: [Equation]
    var currentAttempt = 0
    var isGameOver = false
    var isGameWon = false
    var bottomNumberTiles = Symbol.numbers.map({ Tile(symbol: $0, color: .unusedSymbol) })
    var bottomOperatorTiles = Symbol.operators.map({ Tile(symbol: $0, color: .unusedSymbol) })
    var currentEquation: Equation { equations[currentAttempt] }
    
    init(hiddenEquation: Equation, equations: [Equation]? = nil) {
        id = UUID().uuidString
        self.hiddenEquation = hiddenEquation
        if let equations {
            self.equations = equations
        } else {
            self.equations = []
            for _ in 0 ..< maximumAttempts {
                self.equations.append(Equation(lenght: hiddenEquation.length))
            }
        }
    }
    
    init(
        id: String,
        hiddenEquation: Equation,
        equations: [Equation],
        currentAttempt: Int,
        isGameOver: Bool,
        isGameWon: Bool,
        bottomNumberTiles: [Tile],
        bottomOperatorTiles: [Tile]
    ) {
        self.id = id
        self.hiddenEquation = hiddenEquation
        self.equations = equations
        self.currentAttempt = currentAttempt
        self.isGameOver = isGameOver
        self.isGameWon = isGameWon
        self.bottomNumberTiles = bottomNumberTiles
        self.bottomOperatorTiles = bottomOperatorTiles
    }
}

extension Game {
    static let defaultGame = Game(hiddenEquation: Equation(string: "1+2+3=6")!)
}
