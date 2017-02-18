import Foundation
import RxSwift

public protocol CreatePostUseCase {
    func create(post: Post) -> Observable<Void>
}
