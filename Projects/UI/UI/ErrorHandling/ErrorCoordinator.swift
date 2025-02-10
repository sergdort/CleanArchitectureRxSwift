import Dependencies
import PopupView
import SwiftUI

// Open so it could be ovveriden for Unit Tests
// as @Observable does not work with protocols
@Observable
open class ErrorToastCoordinator {
    var shouldShow: Bool = false

    open func show() {
        shouldShow = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.shouldShow = false
        }
    }
}

extension ErrorToastCoordinator: DependencyKey {
    public static var liveValue: ErrorToastCoordinator {
        ErrorToastCoordinator()
    }
}

public extension DependencyValues {
    var errorToastCoordinator: ErrorToastCoordinator {
        get {
            self[ErrorToastCoordinator.self]
        }
        set {
            self[ErrorToastCoordinator.self] = newValue
        }
    }
}

struct ErrorShowing: ViewModifier {
    @Bindable var coordinator: ErrorToastCoordinator

    init() {
        @Dependency(\.errorToastCoordinator) var coordinator
        self.coordinator = coordinator
    }

    func body(content: Content) -> some View {
        content.popup(isPresented: $coordinator.shouldShow) {
            ErrorToast()
        } customize: {
            $0
                .type(.toast)
                .position(.top)
        }
    }
}

struct ErrorToast: View {
    var body: some View {
        Text("Somethign went wrong")
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 60, leading: 32, bottom: 16, trailing: 32))
            .frame(maxWidth: .infinity)
            .background(Color.red)
    }
}

public extension View {
    func errorShowing() -> some View {
        modifier(ErrorShowing())
    }
}
