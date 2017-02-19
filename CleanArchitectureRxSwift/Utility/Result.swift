import Foundation

protocol ResultType {
    associatedtype T
    var data: T? {get}
    var error: Error? {get}
}

enum Result<T> {
    case data(T)
    case error(Error)
}

extension Result: ResultType {
    var data: T? {
        switch self {
        case .data(let d):
            return d
        default:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .error(let e):
            return e
        default:
            return nil
        }
    }
}
