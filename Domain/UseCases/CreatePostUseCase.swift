import Foundation
import RxSwift

public protocol SavePostUseCase {
    func save(post: Post) -> Observable<Void>
}
