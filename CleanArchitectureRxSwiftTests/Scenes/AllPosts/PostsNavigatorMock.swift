@testable import CleanArchitectureRxSwift
import Domain
import RxSwift

class PostNavigatorMock: PostsNavigator {

  var toPosts_Called = false

  func toPosts() {
    toPosts_Called = true
  }

  var toCreatePost_Called = false

  func toCreatePost() {
    toCreatePost_Called = true
  }

  var toPost_post_Called = false
  var toPost_post_ReceivedArguments: Post?

  func toPost(_ post: Post) {
    toPost_post_Called = true
    toPost_post_ReceivedArguments = post
  }
  
}
