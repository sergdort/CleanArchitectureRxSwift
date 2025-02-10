import Apollo
import ApolloAPI
import Foundation
import Combine

public extension ApolloClient {
    func fetch<Query: GraphQLQuery>(query: Query) async throws -> Query.Data {
        let holder = CancellableHolder()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                holder.value = self.fetch(query: query) { result in
                    switch result {
                    case .success(let gqlResutl):
                        if let data = gqlResutl.data {
                            continuation.resume(returning: data)
                        } else if let error = gqlResutl.errors?.first {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(throwing: NoDataError())
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        } onCancel: {
            holder.cancel()
        }
    }
}
