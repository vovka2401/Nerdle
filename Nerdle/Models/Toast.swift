import Foundation

struct Toast: Identifiable, Equatable {
    let id = UUID().uuidString
    let message: String
}
