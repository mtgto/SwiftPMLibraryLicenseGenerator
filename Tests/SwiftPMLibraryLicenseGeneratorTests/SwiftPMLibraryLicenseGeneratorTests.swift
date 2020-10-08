import XCTest

import class Foundation.Bundle

@testable import SwiftPMLibraryLicenseGeneratorCore

extension Package: Equatable {
  public static func == (lhs: Package, rhs: Package) -> Bool {
    return lhs.name == rhs.name && lhs.repositoryURL == rhs.repositoryURL
  }
}

final class SwiftPMLibraryLicenseGeneratorTests: XCTestCase {
  private func assertValidRepositoryURL(
    repositoryURL: URL, expectedOwner: String, expectedName: String
  ) {
    switch parseRepositoryURL(repositoryURL: repositoryURL) {
    case .success((owner: let owner, name: let name)):
      XCTAssertEqual(expectedOwner, owner)
      XCTAssertEqual(expectedName, name)
    case .failure(let error):
      XCTFail("Error: \(error)")
    }
  }

  private func assertInvalidRepositoryURL(repositoryURL: URL) {
    switch parseRepositoryURL(repositoryURL: repositoryURL) {
    case .success((owner: _, name: _)):
      XCTFail()
    case .failure(_):
      break
    }
  }

  func testParseRepositoryURL() {
    assertValidRepositoryURL(
      repositoryURL: URL(string: "https://github.com/mtgto/SwiftPMLibraryLicenseGenerator.git")!,
      expectedOwner: "mtgto", expectedName: "SwiftPMLibraryLicenseGenerator")
    // github allow repository url without ".git"
    assertValidRepositoryURL(
      repositoryURL: URL(string: "https://github.com/mtgto/SwiftPMLibraryLicenseGenerator")!,
      expectedOwner: "mtgto", expectedName: "SwiftPMLibraryLicenseGenerator")
    // domain may be capitalized
    assertValidRepositoryURL(
      repositoryURL: URL(string: "https://GiThUb.CoM/mtgto/SwiftPMLibraryLicenseGenerator.git")!,
      expectedOwner: "mtgto", expectedName: "SwiftPMLibraryLicenseGenerator")
    // github only
    assertInvalidRepositoryURL(
      repositoryURL: URL(string: "https://gitlab.com/inkscape/inkscape.git")!)

  }

  func testPackagesFromPackageResolved() throws {
    // "swift test" fails (to fix, change it to "Bundle.module")
    let bundle = Bundle(for: type(of: self))
    let path = bundle.path(forResource: "Package", ofType: "resolved")!
    let packages = try Generator().packagesFromPackageResolved(resolvedFilePath: path)
    let expectedPackages = [
      Package(name: "AEXML", repositoryURL: URL(string: "https://github.com/tadija/AEXML")!),
      Package(
        name: "Apollo",
        repositoryURL: URL(string: "https://github.com/apollographql/apollo-ios.git")!),
      Package(name: "PathKit", repositoryURL: URL(string: "https://github.com/kylef/PathKit")!),
      Package(name: "Spectre", repositoryURL: URL(string: "https://github.com/kylef/Spectre.git")!),
      Package(
        name: "SQLite.swift",
        repositoryURL: URL(string: "https://github.com/stephencelis/SQLite.swift.git")!),
      Package(
        name: "Starscream", repositoryURL: URL(string: "https://github.com/daltoniam/Starscream")!),
      Package(
        name: "Stencil",
        repositoryURL: URL(string: "https://github.com/stencilproject/Stencil.git")!),
      Package(
        name: "swift-argument-parser",
        repositoryURL: URL(string: "https://github.com/apple/swift-argument-parser")!),
      Package(
        name: "swift-nio-zlib-support",
        repositoryURL: URL(string: "https://github.com/apple/swift-nio-zlib-support.git")!),
      Package(
        name: "XcodeProj", repositoryURL: URL(string: "https://github.com/tuist/xcodeproj.git")!),
      Package(
        name: "XcodeProjCExt", repositoryURL: URL(string: "https://github.com/tuist/XcodeProjCExt")!
      ),
    ]
    XCTAssertEqual(expectedPackages, packages)
  }

  static var allTests = [
    ("testParseRepositoryURL", testParseRepositoryURL)
  ]
}
