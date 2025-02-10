import Dependencies
import MoviesDomain
import SwiftUI
import UI

public struct PersonDetailsView: View {
    let viewModel: PersonDetailsViewViewModel
    
    public init(viewModel: PersonDetailsViewViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if let movieDetails = viewModel.props.details {
                render(details: movieDetails)
            } else {
                ProgressView()
            }
        }
        .task {
            await viewModel.fetch()
        }
        .navigationTitle(viewModel.person.name)
    }
    
    private func render(details: PersonDetails) -> some View {
        List {
            Section {
                PersonBiographyView(personDetails: details)
                BiographyView(details: details)
                
                VStack {
                    PersonImagesRow(images: details.images.profiles)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#if DEBUG
#Preview {
    PersonDetailsView(
        viewModel: withDependencies({ dependencies in
            let mock = MockPersonDetailsUseCase()
            mock._fetchPersonDetails = { _ in
                PersonDetails.example
            }
            dependencies.personDetailsUseCase = mock
        }, operation: {
            PersonDetailsViewViewModel(person: .example)
        })
    )
}

#endif

struct BiographyView: View {
    var details: PersonDetails
    
    @State
    var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Biography")
                .foregroundColor(.primary)
                .font(.headline)
            
            Text(details.biography)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(isExpanded ? nil : 4)
            Button(action: {
                isExpanded.toggle()
            }) {
                Text(isExpanded ? "Less..." : "More...")
            }
        }
    }
}

struct PersonImagesRow: View {
    let images: [PersonDetails.Image]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Images")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(images, id: \PersonDetails.Image.filePath) { image in
                        PosterImageView(
                            posterSize: .small,
                            posterURL: ImageSize.cast.path(poster: image.filePath)
                        )
                    }
                }
            }
        }
    }
}
