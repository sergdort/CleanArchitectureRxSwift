import ProjectDescription

enum FeaturesModuleName: String, CaseIterable {
    case Movies
    case Anime
    case Watchlist
}

extension FeaturesModuleName {
    var target: Target {
        switch self {
        case .Movies:
            return .feature(
                self,
                domains: [
                    .MoviesDomain
                ],
                external: [
                    .Dependencies
                ]
            )
        case .Anime:
            return .feature(
                self,
                domains: [
                    .AnimeDomain
                ],
                external: [
                    .Dependencies,
                    .ComposableArchitecture
                ]
            )
        case .Watchlist:
          return .feature(
            self,
            domains: [
              .AnimeDomain,
              .MoviesDomain
            ],
            external: [
              .Dependencies
            ]
          )
        }
    }
}

extension Target {
    static func feature(
        _ name: FeaturesModuleName,
        domains: [DomainModuleName],
        external: [ExternalDependenciesName] = []
    ) -> Self {
        .target(
            name: name.rawValue,
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sergdort.\(name.rawValue)",
            sources: ["\(name.rawValue)/**"],
            dependencies: .build {
                domains.map(TargetDependency.fromDomain)
                TargetDependency.fromUI(.UI)
                external.map(TargetDependency.external)
            }
        )
    }
}

extension TargetDependency {
    static func fromFeatures(_ name: FeaturesModuleName) -> Self {
        .project(target: name.rawValue, path: .path("../Features"))
    }
}
