// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftPMLibraryLicenseGenerator",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .executable(
      name: "swift-pm-library-license-generator", targets: ["SwiftPMLibraryLicenseGenerator"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(
      name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser",
      .upToNextMinor(from: "1.0.1")),
    .package(
      name: "Apollo", url: "https://github.com/apollographql/apollo-ios.git",
      .upToNextMinor(from: "0.49.1")),
    .package(
      name: "XcodeProj", url: "https://github.com/tuist/xcodeproj.git",
      .upToNextMajor(from: "8.5.0")),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "SwiftPMLibraryLicenseGenerator",
      dependencies: ["SwiftPMLibraryLicenseGeneratorCore"],
      resources: [
        .copy("Resources")
      ]),
    .target(
      name: "SwiftPMLibraryLicenseGeneratorCore",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"), "Apollo", "XcodeProj",
      ],
      exclude: ["schema.json", "query.graphql"]),
    .testTarget(
      name: "SwiftPMLibraryLicenseGeneratorTests",
      dependencies: ["SwiftPMLibraryLicenseGenerator"],
      resources: [
        .copy("Resources")
      ]),
  ]
)
