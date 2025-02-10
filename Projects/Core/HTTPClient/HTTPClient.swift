import Foundation

public protocol DataFetching {
    func fetch(resource: Resource) async throws -> Data
}

public final class HTTPClient: DataFetching {
    private let session: URLSessionProtocol
    private let environment: Environment
    private let urlComponentsInterceptor: URLComponentsInterceptor
    
    public init(
        session: URLSessionProtocol = URLSession.shared,
        environment: Environment,
        urlComponentsInterceptor: URLComponentsInterceptor
    ) {
        self.session = session
        self.environment = environment
        self.urlComponentsInterceptor = urlComponentsInterceptor
    }
    
    public func fetch(resource: Resource) async throws -> Data {
        let request = request(for: resource)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }
            
            return data
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.notConnectedToInternet
        } catch let error as URLError where error.code == .cancelled {
            throw NetworkError.cancelled
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    private func request(for resource: Resource) -> URLRequest {
        var components = URLComponents()
        
        components.scheme = environment.schema
        components.host = environment.host
        components.path = "/" + environment.version + resource.path
        components.queryItems = resource.query.map { key, value in URLQueryItem(name: key, value: value) }
        
        urlComponentsInterceptor.modify(components: &components)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = resource.method.rawValue
        
        return request
    }
}

public enum NetworkError: Error {
    case networkError(Error)
    case invalidResponse
    case cancelled
    case notConnectedToInternet
}

public extension HTTPClient {
    struct Environment {
        let schema: String
        let host: String
        let version: String
        
        public init(schema: String, host: String, version: String) {
            self.schema = schema
            self.host = host
            self.version = version
        }
    }
}
