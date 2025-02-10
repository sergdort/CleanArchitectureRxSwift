import Foundation

public struct Resource {
    
    public let path: String
    public let method: HTTPMethod
    public let query: [String : String]

    public init(path: String, method: HTTPMethod = .GET, query: [String: String] = [:]) {
        self.path = path
        self.method = method
        self.query = query
    }
}
