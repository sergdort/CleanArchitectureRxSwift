import Foundation

public struct Location {
    public let uid: String
    public let latitude: Double
    public let longitude: Double
    public let name: String
    
    public init(uid: String,
                latitude: Double,
                longitude: Double,
                name: String) {
        self.uid = uid
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
    }
}

extension Location: Equatable {
    public static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.name == rhs.name
    }
}
