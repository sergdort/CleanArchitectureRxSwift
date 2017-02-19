import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    func toResultDriver() -> Driver<Result<E>> {
        return map(Result.data)
            .asDriver {
                return Driver.just(Result.error($0))
            }
    }
}

extension SharedSequenceConvertibleType where E: ResultType {
    func filterError() -> SharedSequence<SharingStrategy, Error> {
        return flatMap { state -> SharedSequence<SharingStrategy, Error> in
            if let error = state.error {
                return SharedSequence.just(error)
            }
            return SharedSequence.empty()
        }
    }
    
    func filterData() -> SharedSequence<SharingStrategy, E.T> {
        return flatMap { state -> SharedSequence<SharingStrategy, E.T> in
            if let data = state.data {
                return SharedSequence.just(data)
            }
            return SharedSequence.empty()
        }
    }
}


