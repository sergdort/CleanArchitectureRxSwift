import SwiftUI
import MoviesDomain
import MoviesAPI
import Movies

@main
struct ModernCleanArchitectureApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .errorShowing()
                .tint(.orange)
        }
    }
}
