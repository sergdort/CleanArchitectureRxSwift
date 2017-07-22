protocol DomainConvertibleType {
    associatedtype DomainType
    
    init(with domain: DomainType)
    
    func asDomain() -> DomainType
}

typealias DomainConvertibleCoding = NSCoding & DomainConvertibleType

protocol Encodable {
    associatedtype Encoder: DomainConvertibleCoding
    
    var encoder: Encoder { get }
}
