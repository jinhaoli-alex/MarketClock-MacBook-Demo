// Entry point

import SwiftUI

@main
struct GlobalMarketClockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 400)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar) // Modern, clean look
    }
}
