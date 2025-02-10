import Combine
import Dependencies
import MoviesDomain
import SwiftUI
import UI

public struct CreateCustomListView: View {
    @Bindable
    var viewModel: CreateCustomListViewModel
  
    public init(viewModel: CreateCustomListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section(header: Text("List information")) {
                HStack {
                    Text("Name:")
                    TextField("Name your list", text: $viewModel.props.listName)
                }
            }
            Section(header: Text("List cover")) {
                if let selectedImage = viewModel.props.selectedImage {
                    BackdropImageView(posterURL: ImageSize.medium.path(poster: selectedImage.path))
                        .frame(width: 280, height: 168)
                    
                    Button(action: viewModel.removeCover) {
                        Text("Remove cover")
                            .foregroundStyle(Color.red)
                    }
                } else {
                    SearchImageRow(
                        imageQuery: $viewModel.props.imageNameQuery,
                        queryDidChange: viewModel.search(query:)
                    )
                    if viewModel.props.images.isEmpty == false {
                        PostersRow(images: viewModel.props.images) { image in
                            viewModel.didSelect(image: image)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: viewModel.didTapCancel, label: {
                    Text("Cancel")
                })
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.didTapCreate, label: {
                    Text("Create")
                })
                .disabled(viewModel.props.canCreate == false)
            }
        }
        .navigationTitle("New list")
    }
}

struct SearchImageRow: View {
    var imageQuery: Binding<String>
    var queryDidChange: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search image", text: imageQuery)
                .onChange(of: imageQuery.wrappedValue) { _, newValue in
                    queryDidChange(newValue)
                }
        }
    }
}

struct PostersRow: View {
    var images: [MovieImage]
    var didTapImage: (MovieImage) -> Void
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(images, id: \.path) { image in
                    BackdropImageView(posterURL: ImageSize.medium.path(poster: image.path))
                        .frame(width: 280, height: 168)
                        .containerShape(Rectangle())
                        .onTapGesture {
                            didTapImage(image)
                        }
                }
            }
        }
    }
}

@MainActor
@Observable
public final class CreateCustomListViewModel {
    var props = Props()
  
    @ObservationIgnored
    @Dependency(\.movieListUseCase)
    private var movieListUseCase: any MovieListUseCase
    
    @ObservationIgnored
    @Dependency(\.movieSearchUseCase)
    private var movieSearchUseCase: any MovieSearchUseCase
    
    @ObservationIgnored
    @Dependency(\.errorToastCoordinator)
    private var errorToast
  
    private let coordinator: CreateCustomListCoordinator
    private let didCreateList: () -> Void
    
    @ObservationIgnored
    private var searchTask: Task<Void, Never>?
    
    @ObservationIgnored
    private lazy var debouncer = Debouncer<String>(delay: 0.5, work: self.debounced(query:))
  
    public init(coordinator: CreateCustomListCoordinator, didCreateList: @escaping () -> Void) {
        self.coordinator = coordinator
        self.didCreateList = didCreateList
    }

    struct Props {
        var listName: String = ""
        var imageNameQuery: String = ""
        var selectedImage: MovieImage?
        var images: [MovieImage] = []
    
        var canCreate: Bool {
            listName.isEmpty == false
        }
    }
  
    func didTapCreate() {
        do {
            try movieListUseCase.create(name: props.listName, imagePath: props.selectedImage?.path)
            coordinator.dismissCreateList()
            didCreateList()
        } catch {
            errorToast.show()
        }
    }
    
    func search(query: String) {
        debouncer.trigger(query)
    }
    
    func didSelect(image: MovieImage) {
        props.selectedImage = image
    }
    
    func removeCover() {
        props.selectedImage = nil
    }
    
    private func debounced(query: String) {
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            do {
                let pageResult = try await movieSearchUseCase.search(query: query, page: 1)
                self.props.images = pageResult.results.compactMap(\.backdropPath)
                    .map(MovieImage.init(path:))
            } catch {
                self.props.images = []
                errorToast.show()
            }
        }
    }
  
    func didTapCancel() {
        coordinator.dismissCreateList()
    }
}

public protocol CreateCustomListCoordinator {
    func dismissCreateList()
}

final class Debouncer<Value> {
    private let delay: TimeInterval
    private let subject = PassthroughSubject<Value, Never>()
    private let cancel: Cancellable?
    
    init(delay: TimeInterval, work: @escaping (Value) -> Void) {
        self.delay = delay
        self.cancel = subject
            .debounce(for: .seconds(delay), scheduler: DispatchQueue.main)
            .sink(receiveValue: work)
    }
    
    func trigger(_ value: Value) {
        subject.send(value)
    }
}
