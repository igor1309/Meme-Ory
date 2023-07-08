// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "swift-meme-ory",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .singleStoryComponent,
        .storyImporter,
    ],
    dependencies: [
    ],
    targets: [
        .singleStoryComponent,
        .singleStoryComponentTests,
        .storyImporter,
        .storyImporterTests,
    ]
)

private extension Product {
    
    static let singleStoryComponent = library(
        name: .singleStoryComponent,
        targets: [.singleStoryComponent]
    )
    static let storyImporter = library(
        name: .storyImporter,
        targets: [.storyImporter]
    )
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
    static let storyImporter = target(
        name: .storyImporter
    )
    static let storyImporterTests =  testTarget(
        name: .storyImporterTests,
        dependencies: [
            .storyImporter
        ]
    )
}

private extension Target.Dependency {
    
    static let singleStoryComponent = byName(
        name: .singleStoryComponent
    )
    static let storyImporter = byName(
        name: .storyImporter
    )
}

private extension String {
    
    static let singleStoryComponent = "SingleStoryComponent"
    static let singleStoryComponentTests = "SingleStoryComponentTests"
    
    static let storyImporter = "StoryImporter"
    static let storyImporterTests = "StoryImporterTests"
}
