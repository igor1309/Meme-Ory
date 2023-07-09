// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "swift-meme-ory-services",
    products: [
        .reminderAPI,
    ],
    targets: [
        .reminderAPI,
        .reminderAPITests,
    ]
)

private extension Product {
    
    static let reminderAPI = library(
        name: .reminderAPI,
        targets: [
            .reminderAPI
        ]
    )
}

private extension Target {
    
    static let reminderAPI = target(
        name: .reminderAPI
    )
    static let reminderAPITests = testTarget(
        name: .reminderAPITests,
        dependencies: [
            .reminderAPI
        ]
    )
}

private extension Target.Dependency {
    
    static let reminderAPI = byName(name: .reminderAPI)
}

private extension String {
    
    static let reminderAPI = "ReminderAPI"
    static let reminderAPITests = "ReminderAPITests"
}
