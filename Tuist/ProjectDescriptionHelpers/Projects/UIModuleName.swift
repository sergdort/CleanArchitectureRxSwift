import ProjectDescription

enum UIModuleName: String, CaseIterable {
    case UI
}

extension UIModuleName {
    var target: Target {
        .target(
            name: rawValue,
            destinations: .iOS,
            product: .framework,
            bundleId: "com.sergdort.\(rawValue)",
            sources: ["\(rawValue)/**"],
            dependencies: [
                .external(.PopupView),
                .external(.Dependencies),
                .external(.ComposableArchitecture)
            ]
        )
    }
}

extension TargetDependency {
    static func fromUI(_ name: UIModuleName) -> Self {
        .project(target: name.rawValue, path: .path("../UI"))
    }
}
