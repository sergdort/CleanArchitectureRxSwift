import HTTPClient
import Dependencies
import Foundation

extension HTTPClient: @retroactive DependencyKey {
    public static var liveValue: HTTPClient {
        HTTPClient(
            session: URLSession(configuration: .ephemeral),
            environment: HTTPClient.Environment(
                schema: "https",
                host: "api.themoviedb.org",
                version: "3"
            ),
            urlComponentsInterceptor: APIKeyInterceptor()
        )
    }
}

extension DependencyValues {
    var httpClient: HTTPClient {
        get {
            self[HTTPClient.self]
        }
        set {
            self[HTTPClient.self] = newValue
        }
    }
}

struct APIKeyInterceptor: URLComponentsInterceptor {
    func modify(components: inout URLComponents) {
        var queryItems = components.queryItems ?? []
        queryItems.append(
            URLQueryItem(name: "api_key", value: "1d9b898a212ea52e283351e521e17871")
        )
        components.queryItems = queryItems
    }
}
