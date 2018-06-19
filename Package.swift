// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Console",
    products: [
        .library(name: "Console", targets: ["Console"])
    ],
    targets: [
        .target(
	    name: "Console",
	    dependencies: []
	),
	.testTarget(name: "ConsoleTests", dependencies: ["Console"])
    ]
)
