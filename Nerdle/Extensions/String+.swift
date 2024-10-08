import Foundation

extension String {
    var expression: NSExpression {
        NSExpression(format: self)
    }
}
