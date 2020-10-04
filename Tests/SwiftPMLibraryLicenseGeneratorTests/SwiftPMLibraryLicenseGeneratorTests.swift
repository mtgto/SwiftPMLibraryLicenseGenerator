import XCTest

import class Foundation.Bundle

@testable import SwiftPMLibraryLicenseGeneratorCore

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
    // domain may be capitalized
    assertValidRepositoryURL(
      repositoryURL: URL(string: "https://GiThUb.CoM/mtgto/SwiftPMLibraryLicenseGenerator.git")!,
      expectedOwner: "mtgto", expectedName: "SwiftPMLibraryLicenseGenerator")
    // github only
    assertInvalidRepositoryURL(
      repositoryURL: URL(string: "https://gitlab.com/inkscape/inkscape.git")!)

  }

  static var allTests = [
    ("testParseRepositoryURL", testParseRepositoryURL)
  ]
}
