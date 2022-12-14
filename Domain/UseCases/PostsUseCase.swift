import Foundation
import RxSwift

public protocol PostsUseCase {
    func posts() -> Observable<[Post]>
    func save(post: Post) -> Observable<Void>
    func delete(post: Post) -> Observable<Void>
    func getList(apiRequest: APIRequest) -> Observable<[UniversityModel]>
    func getFlexiLoan() -> Observable<FlexiLoanModel>
}

extension PostsUseCase {
    func getList(apiRequest: APIRequest) -> Observable<[UniversityModel]> {
        return .just([])
    }
}
