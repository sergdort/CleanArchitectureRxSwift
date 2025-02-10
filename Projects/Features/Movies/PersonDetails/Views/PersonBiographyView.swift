import SwiftUI
import MoviesDomain
import UI

struct PersonBiographyView: View {
    var personDetails: PersonDetails
    
    var body: some View {
        HStack(alignment: .top) {
            PosterImageView(
                posterSize: .medium,
                posterURL: ImageSize.cast.path(poster: personDetails.profilePath ?? "")
            )
            VStack(alignment: .leading) {
                Text("Known for")
                    .font(.headline)
                Text(personDetails.knownForDepartment)
                    .font(.callout)
                
                if let placeOfBirth = personDetails.placeOfBirth {
                    Text("Born at")
                        .font(.headline)
                    Text(placeOfBirth)
                }
            }
        }
    }
}
