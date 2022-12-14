import Foundation
import Domain
import RxSwift
import Realm
import RealmSwift

final class PostsUseCase<Repository>: Domain.PostsUseCase where Repository: AbstractRepository, Repository.T == Post {
    
    func getFlexiLoan() -> RxSwift.Observable<Domain.FlexiLoanModel> {
        
        return .just(FlexiLoanModel.init())
        
    }
    
  
    
    func getList(apiRequest: Domain.APIRequest) -> RxSwift.Observable<[Domain.UniversityModel]> {
        return .just([])
    }
    

    private let repository: Repository

    init(repository: Repository) {
        self.repository = repository
    }

    func posts() -> Observable<[Post]> {
        return repository.queryAll()
    }
    
    func save(post: Post) -> Observable<Void> {
        return repository.save(entity: post)
    }

    func delete(post: Post) -> Observable<Void> {
        return repository.delete(entity: post)
    }
    
}
