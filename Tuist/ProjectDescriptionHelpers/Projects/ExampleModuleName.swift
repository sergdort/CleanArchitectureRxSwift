import ProjectDescription

enum ExampleModuleName: String, CaseIterable {
  case Example
}

extension ExampleModuleName {
  var target: Target {
    switch self {
    case .Example:
      return .target(
        name: rawValue,
        destinations: [.iPhone],
        product: .app,
        bundleId: "com.sergdort.\(rawValue)",
        infoPlist: .file(path: .relativeToManifest("Info.plist")),
        sources: ["Sources/**"],
        resources: ["Resources/**"],
        dependencies: .build {
          FeaturesModuleName.allCases.map(TargetDependency.fromFeatures)
          PlatformModuleName.allCases.map(TargetDependency.fromPlatfrom)
          DomainModuleName.allCases.map(TargetDependency.fromDomain)
          CoreModuleName.allCases.map(TargetDependency.fromCore)
          UIModuleName.allCases.map(TargetDependency.fromUI)

          TargetDependency.external(.Dependencies)
          TargetDependency.external(.SwiftUINavigation)
        }
      )
    }
  }
}
