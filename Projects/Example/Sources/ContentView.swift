import Anime
import AnimeAPI
import AnimeDomain
import Movies
import MoviesAPI
import MoviesDB
import MoviesDomain
import SwiftUI

@MainActor
struct ContentView: View {
  @StateObject
  private var coordinator = AppCoordinator()

  var body: some View {
    TabView {
      coordinator.makeMoviesView()
        .tag(AppCoordinator.Tab.movies)

      coordinator.makeAnimeView()
        .tag(AppCoordinator.Tab.anime)

      coordinator.makeWatchlistsView()
        .tag(AppCoordinator.Tab.watchlist)
    }
  }

  private func tabbarItem(text: String, image: String) -> some View {
    VStack {
      Image(systemName: image)
        .imageScale(.large)
      Text(text)
    }
  }
}
