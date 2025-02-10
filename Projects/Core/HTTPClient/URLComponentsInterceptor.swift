import Foundation

public protocol URLComponentsInterceptor {
    func modify(components: inout URLComponents)
}
