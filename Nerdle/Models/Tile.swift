import SwiftUI
import SwiftData

struct Tile: Identifiable, Equatable, Codable {
    let id: String
    var symbol: Symbol?
    var color: Color
    
    init(id: String = UUID().uuidString, symbol: Symbol? = nil, color: SwiftUI.Color = Color.unknownSymbol) {
        self.id = id
        self.symbol = symbol
        self.color = color
    }
    
    static func ==(lhs: Tile, rhs: Tile) -> Bool {
        lhs.id == rhs.id
    }
}
