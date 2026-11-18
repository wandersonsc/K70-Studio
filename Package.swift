// swift-tools-version: 5.10
import PackageDescription

var products: [Product] = [.library(name: "K70Core", targets: ["K70Core"])]
var targets: [Target] = [
    .target(name: "K70Core"),
    .testTarget(name: "K70CoreTests", dependencies: ["K70Core"])
]

#if os(macOS)
products.append(.executable(name: "K70Studio", targets: ["K70Studio"]))
targets.append(.executableTarget(name: "K70Studio", dependencies: ["K70Core"]))
#endif

let package = Package(
    name: "K70Studio",
    platforms: [.macOS(.v14)],
    products: products,
    targets: targets
)
