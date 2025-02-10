import MoviesDomain
import HTTPClient
import Foundation

public final class PersonDetailsGateway: PersonDetailsUseCase {
    private let client: DataFetching
    private let decoder = JSONDecoder()
    private let dateDormatter = DateFormatter()

    public init(client: DataFetching) {
        self.client = client
        dateDormatter.dateFormat = "YYYY-MM-DD"
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateDormatter)
    }
    
    public func fetchPersonDetails(with id: PersonID) async throws -> PersonDetails {
        let resource = Resource(
            path: "/person/\(id.rawValue)",
            query: [
                "append_to_response": "images"
            ]
        )
        let data = try await client.fetch(resource: resource)
        let person = try decoder.decode(PersonDetails.self, from: data)
        
        return person
    }
}
