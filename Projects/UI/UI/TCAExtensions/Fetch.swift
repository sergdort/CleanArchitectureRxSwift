import ComposableArchitecture
import Foundation

@Reducer
public struct Fetch<Success: Equatable, Params: Equatable> {
    let cancelToken: any Hashable
    let fetch: (Params) async throws -> Success
    
    public init(cancelToken: any Hashable = UUID().uuidString, fetch: @escaping (Params) async throws -> Success) {
        self.cancelToken = cancelToken
        self.fetch = fetch
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetch(let params):
                state = .fetching
                return .run { send in
                    do {
                        let response = try await self.fetch(params)
                        await send(.response(response))
                    } catch {
                        await send(.failure(AnyError(error: error)))
                    }
                }
                .cancellable(id: cancelToken, cancelInFlight: true)
            case .response(let response):
                state = .success(response)
                return .none
            case .failure(let error):
                state = .failure(error)
                return .none
            case .cancel:
                return .cancel(id: cancelToken)
            }
        }
    }
    
    public enum State: Equatable {
        case notInitiated
        case fetching
        case success(Success)
        case failure(AnyError)
        
        public var fetched: Success? {
            switch self {
            case .notInitiated, .fetching:
                return nil
            case .success(let response):
                return response
            case .failure:
                return nil
            }
        }
        
        public var isFetching: Bool {
            switch self {
            case .notInitiated, .success, .failure:
                return false
            case .fetching:
                return true
            }
        }
    }
    
    public enum Action: Equatable {
        case fetch(Params)
        case response(Success)
        case failure(AnyError)
        case cancel
    }
    
    public func errorHandling() -> ErrorHandling<Success, Params> {
        ErrorHandling(fetch: self)
    }
}

public struct AnyError: Error, Equatable {
    let error: Error
    
    public static func == (lhs: AnyError, rhs: AnyError) -> Bool {
        (lhs as NSError) == (rhs.error as NSError)
    }
}

public struct ErrorHandling<Success: Equatable, Params: Equatable>: Reducer {
    public typealias State = Fetch<Success, Params>.State
    public typealias Action = Fetch<Success, Params>.Action
    
    let fetch: Fetch<Success, Params>
    
    @Dependency(\.errorToastCoordinator)
    private var errorToast
    
    public var body: some Reducer<State, Action> {
        fetch
        Reduce { state, action in
            switch action {
            case .failure:
                errorToast.show()
                return .none
            default:
                return .none
            }
        }
    }
}
