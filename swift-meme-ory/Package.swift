// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "swift-meme-ory",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .singleStoryComponent,
    ],
    dependencies: [
    ],
    targets: [
        .singleStoryComponent,
        .singleStoryComponentTests,
    ]
)

private extension Product {
    
    static let singleStoryComponent = library(
        name: .singleStoryComponent,
        targets: [.singleStoryComponent])
}

private extension Target {
    
    static let singleStoryComponent = target(
        name: .singleStoryComponent
    )
    static let singleStoryComponentTests =  testTarget(
        name: .singleStoryComponentTests,
        dependencies: [
            .singleStoryComponent
        ]
    )
}

private extension Target.Dependency {
    
    static let singleStoryComponent = byName(
        name: .singleStoryComponent
    )
}

private extension String {
    
    static let singleStoryComponent = "SingleStoryComponent"
    static let singleStoryComponentTests = "SingleStoryComponentTests"
}
