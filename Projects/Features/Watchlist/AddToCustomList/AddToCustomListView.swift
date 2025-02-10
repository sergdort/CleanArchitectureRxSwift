import Dependencies
import MoviesDomain
import SwiftUI
import UI

public struct AddToCustomListView: View {
    @State
    var viewModel: AddToCustomListViewModel
    
    public init(viewModel: AddToCustomListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            ForEach(viewModel.props.lists, id: \.id) { list in
                MovieListRow(list: list)
                    .withCheckmark(isOn: viewModel.binding(for: list))
            }
        }
        .onAppear {
            viewModel.fetch()
        }
        .navigationTitle(Text("Movie Lists"))
    }
}

@Observable
public final class AddToCustomListViewModel {
    @ObservationIgnored
    @Dependency(\.movieListUseCase)
    private var movieListUseCase: any MovieListUseCase
    
    @ObservationIgnored
    @Dependency(\.errorToastCoordinator)
    private var errorToast
    
    @ObservationIgnored
    public let movie: Movie
    
    var props = Props()
    
    public init(movie: Movie) {
        self.movie = movie
    }
    
    func fetch() {
        do {
            let lists = try movieListUseCase.getCustomLists()
            self.props.lists = lists
        } catch {
            errorToast.show()
        }
    }
    
    func binding(for list: MovieList) -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                list.movies.contains(where: { $0.id == self.movie.id })
            },
            set: { isOn in
                do {
                    if isOn {
                        try self.movieListUseCase.add(movie: self.movie, to: list)
                    } else {
                        try self.movieListUseCase.remove(movie: self.movie, from: list)
                    }
                    self.fetch()
                } catch {
                    self.errorToast.show()
                }
            }
        )
    }

    struct Props {
        var lists: [MovieList] = []
    }
}

