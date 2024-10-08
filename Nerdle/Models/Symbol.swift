import Foundation

enum Symbol: String, CaseIterable, Codable {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    case plus = "+"
    case minus = "-"
    case multiply = "*"
    case divide = "/"
    case equal = "="
}

extension Symbol {
    static let numbers = [Self.one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .zero]
    static let operators = [Self.plus, .minus, .multiply, .divide, .equal]
}
