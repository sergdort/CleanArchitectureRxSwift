import SwiftUI
import Dependencies
import MoviesDomain
import UI

@Observable
public final class PersonDetailsViewViewModel {
    struct Props {
        var details: PersonDetails?
    }
    
    @ObservationIgnored
    @Dependency(\.personDetailsUseCase)
    var personDetailsUseCase: PersonDetailsUseCase
    
    @ObservationIgnored
    @Dependency(\.errorToastCoordinator)
    private var errorToast
    
    var props = Props()
    
    public let person: Person
    
    public init(person: Person) {
        self.person = person
    }
    
    @MainActor
    func fetch() async {
        do {
            let personDetails = try await personDetailsUseCase.fetchPersonDetails(with: person.id)
            props.details = personDetails
        } catch {
            errorToast.show()
        }
    }
}
