import Foundation
import RxSwift

public protocol AllPostsUseCase {
    func posts() -> Observable<[Post]>
}
