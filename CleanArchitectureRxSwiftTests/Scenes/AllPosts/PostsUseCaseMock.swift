@testable import CleanArchitectureRxSwift
import RxSwift
import Domain

class PostsUseCaseMock: Domain.PostsUseCase {
  var posts_ReturnValue: Observable<[Post]> = Observable.just([])
  var posts_Called = false
  var save_ReturnValue: Observable<Void> = Observable.just(())
  var save_Called = false
  var delete_ReturnValue: Observable<Void> = Observable.just(())
  var delete_Called = false

  func posts() -> Observable<[Post]> {
    posts_Called = true
    return posts_ReturnValue
  }

  func save(post: Post) -> Observable<Void> {
    save_Called = true
    return save_ReturnValue
  }

  func delete(post: Post) -> Observable<Void> {
    delete_Called = true
    return delete_ReturnValue
  }
}
