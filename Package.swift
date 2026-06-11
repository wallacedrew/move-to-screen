// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MoveToScreen",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .target(
            name: "MoveToScreenDomain",
            path: "Sources/MoveToScreenDomain"
        ),
        .target(
            name: "MoveToScreenPorts",
            dependencies: ["MoveToScreenDomain"],
            path: "Sources/MoveToScreenPorts"
        ),
        .target(
            name: "MoveToScreenUseCases",
            dependencies: ["MoveToScreenDomain", "MoveToScreenPorts"],
            path: "Sources/MoveToScreenUseCases"
        ),
        .target(
            name: "MoveToScreenAdapters",
            dependencies: ["MoveToScreenDomain", "MoveToScreenPorts"],
            path: "Sources/MoveToScreenAdapters"
        ),
        .target(
            name: "MoveToScreenTestSupport",
            dependencies: ["MoveToScreenDomain", "MoveToScreenPorts"],
            path: "Sources/MoveToScreenTestSupport"
        ),
        .executableTarget(
            name: "MoveToScreen",
            dependencies: [
                "MoveToScreenDomain",
                "MoveToScreenPorts",
                "MoveToScreenUseCases",
                "MoveToScreenAdapters",
            ],
            path: "Sources/MoveToScreen"
        ),
        .testTarget(
            name: "MoveToScreenDomainTests",
            dependencies: ["MoveToScreenDomain"],
            path: "Tests/MoveToScreenDomainTests"
        ),
        .testTarget(
            name: "MoveToScreenUseCasesTests",
            dependencies: [
                "MoveToScreenDomain",
                "MoveToScreenPorts",
                "MoveToScreenUseCases",
                "MoveToScreenTestSupport",
            ],
            path: "Tests/MoveToScreenUseCasesTests"
        ),
        .testTarget(
            name: "MoveToScreenAcceptanceTests",
            dependencies: [
                "MoveToScreenDomain",
                "MoveToScreenPorts",
                "MoveToScreenUseCases",
                "MoveToScreenTestSupport",
            ],
            path: "Tests/MoveToScreenAcceptanceTests"
        ),
    ]
)
