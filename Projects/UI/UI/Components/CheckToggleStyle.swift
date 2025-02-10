import SwiftUI

extension View {
    public func withCheckmark(isOn: Binding<Bool>) -> some View {
        self.modifier(WithCheckmark(isOn: isOn))
    }
}

struct WithCheckmark: ViewModifier {
    let isOn: Binding<Bool>

    func body(content: Content) -> some View {
        HStack {
            content
            Toggle(isOn: isOn) {
                Image(
                    systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
            }
            .toggleStyle(.button)
            .clipShape(Circle())
        }
    }
}
