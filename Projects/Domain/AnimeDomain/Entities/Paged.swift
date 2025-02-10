import Foundation

public struct Paged<T> {
    public let response: T
    public let pageInfo: PageInfo
    
    public init(response: T, pageInfo: PageInfo) {
        self.response = response
        self.pageInfo = pageInfo
    }
}

extension Paged: Equatable where T: Equatable {}
