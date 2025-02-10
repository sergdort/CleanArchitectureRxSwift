public struct PageInfo: Equatable {
    public let currentPage: Int
    public let hasNextPage: Bool
    
    public init(currentPage: Int, hasNextPage: Bool) {
        self.currentPage = currentPage
        self.hasNextPage = hasNextPage
    }
}
