import ProjectDescription
import Foundation

enum PlatformModuleName: String, CaseIterable {
    case MoviesAPI
    case MoviesDB
    case AnimeAPI
    case AnimeDB
}

extension PlatformModuleName {
    var target: Target {
        switch self {
        case .MoviesAPI:
            return .platform(
                self,
                domains: [
                    .MoviesDomain
                ],
                coreDependencies: [
                    .HTTPClient
                ]
            )
        case .MoviesDB:
            return .platform(
                self,
                domains: [
                    .MoviesDomain
                ],
                coreDependencies: [
                    .FileCache,
                    .SwiftDataHelpers
                ]
            )
        case .AnimeAPI:
            return .platform(
                self,
                domains: [
                    .AnimeDomain
                ],
                coreDependencies: [
                    .ApolloExtensions
                ],
                additionalFiles: [
                    .glob(
                        pattern: "\(self.rawValue)/**/*.graphql"
                    )
                ]
            )
        case .AnimeDB:
            return .platform(
                self,
                domains: [
                    .AnimeDomain
                ],
                coreDependencies: [
                    .SwiftDataHelpers
                ]
            )
        }
    }
}

extension Target {
    static func platform(
        _ name: PlatformModuleName,
        domains: [DomainModuleName] = [],
        coreDependencies: [CoreModuleName] = [],
        externalDependencies: [ExternalDependenciesName] = [],
        additionalFiles: [FileElement] = []
    ) -> Self {
        return .target(
            name: name.rawValue,
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sergdort.\(name.rawValue)",
            sources: ["\(name.rawValue)/**"],
            dependencies: .build {
                domains.map(TargetDependency.fromDomain)
                coreDependencies.map(TargetDependency.fromCore)
                externalDependencies.map(TargetDependency.external)
            },
            additionalFiles: additionalFiles
        )
    }
}

extension TargetDependency {
    static func fromPlatfrom(_ name: PlatformModuleName) -> Self {
        .project(target: name.rawValue, path: .path("../Platform"))
    }
}

