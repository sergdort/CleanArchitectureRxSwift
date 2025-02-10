import ProjectDescription

enum DomainModuleName: String, CaseIterable {
    case MoviesDomain
    case AnimeDomain
}

extension DomainModuleName {
    var target: Target {
        .domain(
            name: self,
            external: [
                .Dependencies,
                .XCTestDynamicOverlay,
                .Tagged
            ]
        )
    }
}

extension Target {
    static func domain(
        name: DomainModuleName,
        external: [ExternalDependenciesName]
    ) -> Target {
        .target(
            name: name.rawValue,
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sergdort.\(name.rawValue)",
            sources: ["\(name.rawValue)/**"],
            dependencies: .build {
                external.map(TargetDependency.external)
            }
        )
    }
}

extension TargetDependency {
    static func fromDomain(_ name: DomainModuleName) -> Self {
        .project(
            target: name.rawValue,
            path: .path("../Domain")
        )
    }
}
