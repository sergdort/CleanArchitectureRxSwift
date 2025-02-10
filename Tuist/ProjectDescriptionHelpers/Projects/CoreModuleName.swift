import ProjectDescription

enum CoreModuleName: String, CaseIterable {
    case FileCache
    case HTTPClient
    case ApolloExtensions
    case SwiftDataHelpers
}

extension CoreModuleName {
    var target: Target {
        switch self {
        case .FileCache:
            .target(
                name: rawValue,
                destinations: .iOS,
                product: .framework,
                bundleId: "com.sergdort.\(rawValue)",
                sources: "\(rawValue)/**"
            )
        case .HTTPClient:
            .target(
                name: rawValue,
                destinations: .iOS,
                product: .framework,
                bundleId: "com.sergdort.\(rawValue)",
                sources: "\(rawValue)/**"
            )
        case .ApolloExtensions:
            .target(
                name: rawValue,
                destinations: .iOS,
                product: .framework,
                bundleId: "com.sergdort.\(rawValue)",
                sources: "\(rawValue)/**",
                dependencies: [
                    .external(.Apollo)
                ]
            )
        case .SwiftDataHelpers:
            .target(
                name: rawValue,
                destinations: .iOS,
                product: .framework,
                bundleId: "com.sergdort.\(rawValue)",
                sources: "\(rawValue)/**",
                dependencies: [
                    .external(.Dependencies),
                    .external(.XCTestDynamicOverlay)
                ]
            )
        }
    }
}

extension TargetDependency {
    static func fromCore(_ name: CoreModuleName) -> Self {
        .project(
            target: name.rawValue,
            path: .path("../Core")
        )
    }
}
