import Foundation
import Tagged

public typealias PersonID = Tagged<Person, Int>

public struct Person: Codable, Equatable {
    public var id: PersonID
    public var name: String
    public var knownForDepartment: String?
    public var originalName: String?
    public var popularity: Double?
    public var profilePath: String?
    public var castID: Int?
    public var character: String?
    public var creditID: String?
    public var department: String?
    public var job: String?

    enum CodingKeys: String, CodingKey {
        case id
        case knownForDepartment = "known_for_department"
        case name
        case originalName = "original_name"
        case popularity
        case profilePath = "profile_path"
        case castID = "cast_id"
        case character
        case creditID = "credit_id"
        case department
        case job
    }
}

#if DEBUG
public extension Person {
    static var example: Self {
        Person(id: 42, name: "Tom Hardy")
    }
}
#endif
