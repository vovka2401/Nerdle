import XCTest
@testable import Nerdle

final class NerdleTests: XCTestCase {
    
    private var gameViewModel: GameViewModel!

    override func setUpWithError() throws {
        gameViewModel = GameViewModel()
        gameViewModel.game = Game(hiddenEquation: Equation(string: "1+1+7=9")!)
        gameViewModel.selectedTile = gameViewModel.game.currentEquation.tiles.first!
    }

    override func tearDownWithError() throws {
        gameViewModel = nil
    }

    func testGameIsWonAfterTwoAttempts() throws {
        XCTAssertEqual(gameViewModel.game.currentAttempt, 0)
        setEquation("1+2=3-0")
        gameViewModel.guess()
        XCTAssertEqual(gameViewModel.game.currentAttempt, 1)
        setEquation("1+1+7=9")
        gameViewModel.guess()
        XCTAssertTrue(gameViewModel.game.isGameOver)
        XCTAssertTrue(gameViewModel.game.isGameWon)
    }

    func testGameIsLostAfterSixAttempts() throws {
        XCTAssertEqual(gameViewModel.game.currentAttempt, 0)
        setEquation("1+2=3-0")
        gameViewModel.guess()
        XCTAssertEqual(gameViewModel.game.currentAttempt, 1)
        setEquation("2+2/2=3")
        gameViewModel.guess()
        XCTAssertEqual(gameViewModel.game.currentAttempt, 2)
        setEquation("9/3-3=0")
        gameViewModel.guess()
        XCTAssertEqual(gameViewModel.game.currentAttempt, 3)
        setEquation("0-0-0=0")
        gameViewModel.guess()
        XCTAssertEqual(gameViewModel.game.currentAttempt, 4)
        setEquation("7*2-9=5")
        gameViewModel.guess()
        XCTAssertEqual(gameViewModel.game.currentAttempt, 5)
        setEquation("2*2+2=6")
        gameViewModel.guess()
        XCTAssertTrue(gameViewModel.game.isGameOver)
        XCTAssertFalse(gameViewModel.game.isGameWon)
    }

    func testCurrentAttemptDidntChangeAfterSettingInvalidEquation() throws {
        XCTAssertEqual(gameViewModel.game.currentAttempt, 0)
        setEquation("1+2=3+7")
        gameViewModel.guess()
        XCTAssertEqual(gameViewModel.game.currentAttempt, 0)
        XCTAssertFalse(gameViewModel.game.isGameOver)
    }
    
    private func setEquation(_ equation: String) {
        for char in equation {
            guard let symbol = Symbol(rawValue: String(char)) else { return }
            gameViewModel.selectSymbol(symbol)
        }
    }
}
