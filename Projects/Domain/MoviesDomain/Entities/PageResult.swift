public struct PageResult<Item: Codable>: Codable {
    public var page: Int
    public var results: [Item]
    public var totalPages: Int
    public var totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case results = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
    init(page: Int, results: [Item], totalPages: Int, totalResults: Int) {
        self.page = page
        self.results = results
        self.totalPages = totalPages
        self.totalResults = totalResults
    }
}
