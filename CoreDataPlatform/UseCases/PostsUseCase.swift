import Foundation
import Domain
import RxSwift

final class PostsUseCase<Repository>: Domain.PostsUseCase where Repository: AbstractRepository, Repository.T == Post {
    
    func getFlexiLoan() -> RxSwift.Observable<Domain.FlexiLoanModel> {
        return .just(FlexiLoanModel.init(availableLOC: nil, offeredInterestRate: nil, offeredEIR: nil, min: nil, max: nil))
    }
    
    func getList(apiRequest: Domain.APIRequest) -> RxSwift.Observable<[Domain.UniversityModel]> {
        return .just([])
    }
    
    
    
    private let repository: Repository

    init(repository: Repository) {
        self.repository = repository
    }

    func posts() -> Observable<[Post]> {
        return repository.query(with: nil, sortDescriptors: [Post.CoreDataType.createdAt.descending()])
    }
    
    func save(post: Post) -> Observable<Void> {
        return repository.save(entity: post)
    }

    func delete(post: Post) -> Observable<Void> {
        return repository.delete(entity: post)
    }
    
//    func getList(apiRequest: Domain.APIRequest) -> RxSwift.Observable<[Domain.UniversityModel]> {
//        return repository.query(with: <#T##NSPredicate?#>, sortDescriptors: <#T##[NSSortDescriptor]?#>)
//    }
}
