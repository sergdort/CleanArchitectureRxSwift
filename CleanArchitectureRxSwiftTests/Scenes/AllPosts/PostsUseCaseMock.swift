@testable import CleanArchitectureRxSwift
import Domain
import RxSwift

class PostsUseCaseMock: Domain.PostsUseCase {
	var posts_ReturnValue: Observable<[Post]> = Observable.just([])
	var posts_Called = false

	func posts() -> Observable<[Post]> {
		posts_Called = true
		return posts_ReturnValue
	}

	func save(post: Post) -> Observable<Void> {
		return Observable.never()
	}

	func delete(post: Post) -> Observable<Void> {
		return Observable.never()
	}
}
