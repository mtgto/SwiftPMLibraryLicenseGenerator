// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftPMLibraryLicenseGenerator",
  platforms: [
    .macOS(.v10_15),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(name: "Apollo", url: "https://github.com/apollographql/apollo-ios.git", .upToNextMinor(from: "0.34.1")),
    .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "7.14.0"))
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "SwiftPMLibraryLicenseGenerator",
      dependencies: ["Apollo", "XcodeProj"]),
    .testTarget(
      name: "SwiftPMLibraryLicenseGeneratorTests",
      dependencies: ["SwiftPMLibraryLicenseGenerator"]),
  ]
)
