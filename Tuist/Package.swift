// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [
            "ConcurrencyExtras": .framework,
            "XCTestDynamicOverlay": .framework,
            "CombineSchedulers": .framework,
            "Dependencies": .framework,
            "Clocks": .framework,
            "Tagged": .framework,
            "SwiftUINavigation": .framework,
            "PopupView": .framework,
            "IssueReporting": .framework,
            "ComposableArchitecture": .framework,
            "PerceptionCore": .framework,
            "Perception": .framework,
            "OrderedCollections": .framework,
            "CasePaths": .framework,
            "CustomDump": .framework,
            "SwiftNavigation": .framework,
            "CasePathsCore": .framework,
            "InternalCollectionsUtilities": .framework,
            "UIKitNavigation": .framework,
            "UIKitNavigationShim": .framework
        ]
    )
#endif

let package = Package(
    name: "ModernCleanArchitecture",
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", exact: "1.12.2"),
        .package(url: "https://github.com/pointfreeco/swift-tagged.git", exact: "0.10.0"),
        .package(url: "https://github.com/exyte/PopupView.git", exact: "4.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "1.13.1")
    ]
)
