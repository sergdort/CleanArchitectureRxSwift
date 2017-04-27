import UIKit
import Domain
import Network

protocol PostsNavigator {
    func toCreatePost()
    func toPost(_ post: Post)
    func toPosts()
}

class DefaultPostsNavigator: PostsNavigator {
    private let storyBoard: UIStoryboard
    private let navigationController: UINavigationController
    private let services: UseCaseProvider
    private let network: NetworkProvider
    
    init(services: UseCaseProvider,
         network: NetworkProvider,
         navigationController: UINavigationController,
         storyBoard: UIStoryboard) {
        self.services = services
        self.network = network
        self.navigationController = navigationController
        self.storyBoard = storyBoard
    }
    
    func toPosts() {
        let vc = storyBoard.instantiateViewController(ofType: PostsViewController.self)
        vc.viewModel = PostsViewModel(useCase: services.getAllPostsUseCase(),
                                      navigator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func toCreatePost() {
        let navigator = DefaultCreatePostNavigator(navigationController: navigationController)
        let viewModel = CreatePostViewModel(createPostUseCase: services.getCreatePostUseCase(),
                navigator: navigator)
        let vc = storyBoard.instantiateViewController(ofType: CreatePostViewController.self)
        vc.viewModel = viewModel
        let nc = UINavigationController(rootViewController: vc)
        navigationController.present(nc, animated: true, completion: nil)
    }
    
    func toPost(_ post: Post) {
        let vc = storyBoard.instantiateViewController(ofType: EditPostViewController.self)
        let viewModel = EditPostViewModel(post: post, useCase: services.getCreatePostUseCase())
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
}
