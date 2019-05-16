@testable import CleanArchitectureRxSwift
import Domain
import XCTest
import RxSwift
import RxCocoa
import RxBlocking

enum TestError: Error {
  case test
}

class PostsViewModelTests: XCTestCase {

  var allPostUseCase: PostsUseCaseMock!
  var postsNavigator: PostNavigatorMock!
  var viewModel: PostsViewModel!

  let disposeBag = DisposeBag()

  override func setUp() {
    super.setUp()

    allPostUseCase = PostsUseCaseMock()
    postsNavigator = PostNavigatorMock()

    viewModel = PostsViewModel(useCase: allPostUseCase,
                               navigator: postsNavigator)
  }

  func test_transform_triggerInvoked_postEmited() {
    // arrange
    let trigger = PublishSubject<Void>()
    let input = createInput(trigger: trigger)
    let output = viewModel.transform(input: input)

    // act
    output.posts.drive().disposed(by: disposeBag)
    trigger.onNext(())

    // assert
    XCTAssert(allPostUseCase.posts_Called)
  }


  func test_transform_sendPost_trackFetching() {
    // arrange
    let trigger = PublishSubject<Void>()
    let output = viewModel.transform(input: createInput(trigger: trigger))
    let expectedFetching = [true, false]
    var actualFetching: [Bool] = []

    // act
    output.fetching
      .do(onNext: { actualFetching.append($0) },
          onSubscribe: { actualFetching.append(true) })
      .drive()
      .disposed(by: disposeBag)
    trigger.onNext(())

    // assert
    XCTAssertEqual(actualFetching, expectedFetching)
  }

  func test_transform_postEmitError_trackError() {
    // arrange
    let trigger = PublishSubject<Void>()
    let output = viewModel.transform(input: createInput(trigger: trigger))
    allPostUseCase.posts_ReturnValue = Observable.error(TestError.test)

    // act
    output.posts.drive().disposed(by: disposeBag)
    output.error.drive().disposed(by: disposeBag)
    trigger.onNext(())
    let error = try! output.error.toBlocking().first()

    // assert
    XCTAssertNotNil(error)
  }

  func test_transform_triggerInvoked_mapPostsToViewModels() {
    // arrange
    let trigger = PublishSubject<Void>()
    let output = viewModel.transform(input: createInput(trigger: trigger))
    allPostUseCase.posts_ReturnValue = Observable.just(createPosts())

    // act
    output.posts.drive().disposed(by: disposeBag)
    trigger.onNext(())
    let posts = try! output.posts.toBlocking().first()!

    // assert
    XCTAssertEqual(posts.count, 2)
  }

  func test_transform_selectedPostInvoked_navigateToPost() {
    // arrange
    let select = PublishSubject<IndexPath>()
    let output = viewModel.transform(input: createInput(selection: select))
    let posts = createPosts()
    allPostUseCase.posts_ReturnValue = Observable.just(posts)

    // act
    output.posts.drive().disposed(by: disposeBag)
    output.selectedPost.drive().disposed(by: disposeBag)
    select.onNext(IndexPath(row: 1, section: 0))

    // assert
    XCTAssertTrue(postsNavigator.toPost_post_Called)
    XCTAssertEqual(postsNavigator.toPost_post_ReceivedArguments, posts[1])
  }

  func test_transform_createPostInvoked_navigateToCreatePost() {
    // arrange
    let create = PublishSubject<Void>()
    let output = viewModel.transform(input: createInput(createPostTrigger: create))
    let posts = createPosts()
    allPostUseCase.posts_ReturnValue = Observable.just(posts)

    // act
    output.posts.drive().disposed(by: disposeBag)
    output.createPost.drive().disposed(by: disposeBag)
    create.onNext(())

    // assert
    XCTAssertTrue(postsNavigator.toCreatePost_Called)
  }

  private func createInput(trigger: Observable<Void> = Observable.just(()),
                           createPostTrigger: Observable<Void> = Observable.never(),
                           selection: Observable<IndexPath> = Observable.never())
    -> PostsViewModel.Input {
      return PostsViewModel.Input(
        trigger: trigger.asDriverOnErrorJustComplete(),
        createPostTrigger: createPostTrigger.asDriverOnErrorJustComplete(),
        selection: selection.asDriverOnErrorJustComplete())
  }

  private func createPosts() -> [Post] {
    return [
      Post(body: "body 1", title: "title 1", uid: "uid 1", userId: "userId 1", createdAt: "created at 1"),
      Post(body: "body 2", title: "title 2", uid: "uid 2", userId: "userId 2", createdAt: "created at 2")
    ]
  }
}
