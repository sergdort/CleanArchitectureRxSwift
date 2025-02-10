import Foundation
import Apollo

final class CancellableHolder: @unchecked Sendable {
    private var lock = NSRecursiveLock()
    private var innerCancellable: Cancellable?

    private func synced<Result>(_ action: () throws -> Result) rethrows -> Result {
        lock.lock()
        defer { lock.unlock() }
        return try action()
    }

    var value: Cancellable? {
        get { synced { innerCancellable } }
        set { synced { innerCancellable = newValue } }
    }

    func cancel() {
        synced { innerCancellable?.cancel() }
    }
}
