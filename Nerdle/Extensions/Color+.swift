import SwiftUI

extension Color {
    static let unknownSymbol = Color(red: 0.592, green: 0.581, blue: 0.525)
    static let rightPositionSymbol = Color(red: 0.31, green: 0.525, blue: 0.459)
    static let wrongPositionSymbol = Color(red: 0.467, green: 0.09, blue: 0.337)
    static let absentSymbol = Color(red: 0.086, green: 0.094, blue: 0.02)
    static let unusedSymbol = Color(red: 0.89, green: 0.91, blue: 0.937)
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case alpha
    }

    public func encode(to encoder: Encoder) throws {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        var container = encoder.container(keyedBy: CodingKeys.self)
        NSColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(alpha, forKey: .alpha)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let red = try values.decode(CGFloat.self, forKey: .red)
        let green = try values.decode(CGFloat.self, forKey: .green)
        let blue = try values.decode(CGFloat.self, forKey: .blue)
        let alpha = try values.decode(CGFloat.self, forKey: .alpha)
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}
