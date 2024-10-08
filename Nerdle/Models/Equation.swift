import Foundation
import SwiftData

struct Equation: Identifiable, Codable {
    let id: String
    let length: Int
    var tiles: [Tile]
    
    init(id: String = UUID().uuidString, tiles: [Tile]) {
        self.id = id
        self.length = tiles.count
        self.tiles = tiles
    }
    
    init(id: String = UUID().uuidString, lenght: Int) {
        self.id = id
        self.length = lenght
        self.tiles = []
        for _ in 0 ..< lenght {
            tiles.append(Tile())
        }
    }
    
    init(id: String = UUID().uuidString, symbols: [Symbol]) {
        self.id = id
        self.length = symbols.count
        tiles = symbols.map({ Tile(symbol: $0) })
    }
    
    init?(id: String = UUID().uuidString, string: String) {
        var symbols = [Symbol]()
        for char in string {
            guard let symbol = Symbol(rawValue: String(char)) else { return nil }
            symbols.append(symbol)
        }
        self.init(id: id, symbols: symbols)
    }
    
    func isValid() -> Bool {
        let stringEquation = getStringEquation()
        let stringEquationWithDoubles = getStringEquationWithDoubles()
        if tiles.compactMap(\.symbol).count < length {
            return false
        } else if stringEquation.filter({ $0 == "=" }).count == 1,
            let index = stringEquationWithDoubles.firstIndex(of: "="),
                  stringEquation.first != "=",
                  stringEquation.last != "=",
            let leftResult = String(stringEquationWithDoubles.prefix(upTo: index))
                .expression.expressionValue(with: [], context: nil) as? Double,
            let rightResult = String(stringEquationWithDoubles.suffix(from: stringEquationWithDoubles.index(after: index)))
                .expression.expressionValue(with: [], context: nil) as? Double,
            leftResult.rounded() == leftResult,
            rightResult.rounded() == rightResult,
            leftResult.isFinite,
            rightResult.isFinite {
            return Int(leftResult) == Int(rightResult)
        } else {
            return false
        }
    }
    
    private func getStringEquation() -> String {
        tiles.compactMap(\.symbol?.rawValue).reduce("", +)
    }
    
    private func getStringEquationWithDoubles() -> String {
        tiles.compactMap { tile in
            if let symbol = tile.symbol, Symbol.operators.contains(symbol) {
                return ".0\(symbol.rawValue)"
            } else {
                return tile.symbol?.rawValue
            }
        }
        .reduce("", +)
        .appending(".0")
    }
}

extension Equation {
    static func generate(length: Int) -> Equation? {
        guard GameSize.allCases.map(\.rawValue).contains(length) else { return nil }
        let numbers = Symbol.numbers.map(\.rawValue)
        let operators = ["+", "-", "*", "/"]
        var leftHandSide = ""
        let numbersCount: Int
        let operatorsCount: Int
        if length == GameSize.micro.rawValue {
            numbersCount = 2
            operatorsCount = 1
        } else if length == GameSize.mini.rawValue {
            numbersCount = Int.random(in: 2 ... 3)
            operatorsCount = 1
        } else if length == GameSize.classic.rawValue {
            numbersCount = Int.random(in: 3 ... 4)
            operatorsCount = 2
        } else {
            return nil
        }
        var numbersLeft = numbersCount
        var operatorsLeft = operatorsCount
        for i in 0 ..< numbersCount + operatorsCount {
            if i == 0 || i == numbersCount + operatorsCount - 1 || operatorsLeft == 0 {
                leftHandSide += numbers.randomElement()!
                numbersLeft -= 1
            } else if (numbersLeft == 1 && operatorsLeft == 1) || operatorsLeft == numbersLeft {
                leftHandSide += operators.randomElement()!
                operatorsLeft -= 1
            } else {
                leftHandSide += numbers.randomElement()!
                numbersLeft -= 1
            }
        }
        let leftHandSideWithDoubles = leftHandSide.map { char in
            let string = String(char)
            if operators.contains(string) {
                return ".0" + string
            } else {
                return string
            }
        }
            .reduce("", +)
            .appending(".0")
        let expression = NSExpression(format: leftHandSideWithDoubles)
        guard let result = expression.expressionValue(with: nil, context: nil) as? NSNumber,
            result.doubleValue == Double(result.intValue) else {
            return generate(length: length)
        }
        let equation = "\(leftHandSide)=\(result.intValue)"
        guard equation.count == length else {
            return generate(length: length)
        }
        return Equation(string: equation)
    }
    
    static func selectEquationForToday() -> Equation {
        Equation(string: "1+2=3")!
    }
}
