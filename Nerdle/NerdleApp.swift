import SwiftUI
import SwiftData

@main
struct NerdleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Game.self])
    }
}
