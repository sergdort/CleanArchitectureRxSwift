import ProjectDescription

enum ExternalDependenciesName: String {
    case Apollo
    case Dependencies
    case XCTestDynamicOverlay
    case Tagged
    case Clocks
    case ConcurrencyExtras
    case CombineSchedulers
    case SwiftUINavigation
    case PopupView
    case ComposableArchitecture
}

extension TargetDependency {
    static func external(_ name: ExternalDependenciesName) -> Self {
        .external(name: name.rawValue)
    }
}
