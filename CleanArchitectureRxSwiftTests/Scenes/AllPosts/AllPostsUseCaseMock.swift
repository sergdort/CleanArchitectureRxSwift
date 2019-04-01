@testable import CleanArchitectureRxSwift
import Domain
import RxSwift

class AllPostsUseCaseMock: Domain.AllPostsUseCase {
    var posts_ReturnValue: Observable<[Post]> = Observable.just([])
    var posts_Called = false

    func posts() -> Observable<[Post]> {
        posts_Called = true
        return posts_ReturnValue
    }
}
