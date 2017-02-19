import Foundation
import Domain
import RxSwift
import RxCocoa

final class PostsViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<Void>
        let createPostTrigger: Driver<Void>
        let selection: Driver<IndexPath>
    }
    struct Output {
        let fetching: Driver<Bool>
        let posts: Driver<[Post]>
        let createPost: Driver<Void>
        let selectedPost: Driver<Post>
        let errors: Driver<Error>
    }
    
    private let useCase: AllPostsUseCase
    private let navigator: PostsNavigator
    
    init(useCase: AllPostsUseCase, navigator: PostsNavigator) {
        self.useCase = useCase
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let postsState = input.trigger.flatMapLatest {
            return self.useCase.posts()
                .trackActivity(activityIndicator)
                .toResultDriver()
        }
        
        let fetching = activityIndicator.asDriver()
        let posts = postsState.filterData()
        let errors = postsState.filterError()
        let selectedPost = input.selection
            .withLatestFrom(posts) { (indexPath, posts) -> Post in
                return posts[indexPath.row]
            }
            .do(onNext: navigator.toPost)
        let createPost = input.createPostTrigger
            .do(onNext: navigator.toCreatePost)
        
        return Output(fetching: fetching,
                      posts: posts,
                      createPost: createPost,
                      selectedPost: selectedPost,
                      errors: errors)
    }
}
