import Foundation
import RxSwift

extension ObservableType where E == Bool {
    /// Boolean not operator
    public func not() -> Observable<Bool> {
        return self.map(!)
    }
}

extension ObservableType {
    func catchErrorJustComplete() -> Observable<E> {
        return catchError { _ in
            return Observable.empty()
        }
    }
}

extension ObservableType where E: ResultType {
    func filterSuccess() -> Observable<E.T> {
        return flatMap { result -> Observable<E.T> in
            if let data = result.data {
                return Observable.just(data)
            }
            return Observable.empty()
        }
    }
}
