import AppKit
import ArgumentParser
import Combine
import Foundation
import XcodeProj

public enum ExportFormat {
  case json, rtf
}

enum GeneratorError: Error {
  case unsupportedHost, badFormatURL
}

// Minimum definition of swift package of this project
struct Package: Encodable {
  let name: String
  let repositoryURL: URL
}

// The result of fetch
struct PackageLicense: Encodable {
  let package: Package
  let license: String? // content of license file
  let licenseInfo: Result<LicenseInfo, Error>

  enum CodingKeys: String, CodingKey {
    case name
    case repositoryURL
    case error
    case licenseInfo
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(package.name, forKey: .name)
    try container.encode(package.repositoryURL, forKey: .repositoryURL)

    switch self.licenseInfo {
    case .success(let licenseInfo):
      try container.encode(licenseInfo, forKey: .licenseInfo)
    case .failure(let error):
      switch error {
      case GeneratorError.unsupportedHost:
        try container.encode("Currently, it supports github only", forKey: .error)
      case GeneratorError.badFormatURL:
        try container.encode(
          "repository URL of package has bad format or does not exists", forKey: .error)
      default:
        try container.encode(error.localizedDescription, forKey: .error)
      }
    }
  }
}

// https://stackoverflow.com/a/46883516
struct StandardErrorOutputStream: TextOutputStream {
  let stderr = FileHandle.standardError

  func write(_ string: String) {
    guard let data = string.data(using: .utf8) else {
      return
    }
    stderr.write(data)
  }
}

var stderr = StandardErrorOutputStream()

func parseRepositoryURL(repositoryURL: URL) -> Result<(owner: String, name: String), Error> {
  if repositoryURL.host?.lowercased() != "github.com" {
    print("[WARN] Skip  \(repositoryURL) which does not have GitHub domain", to: &stderr)
    return .failure(GeneratorError.unsupportedHost)
  }
  if repositoryURL.pathComponents.count != 3 {
    print("[WARN] Skip \(repositoryURL) which has invalid GitHub URL", to: &stderr)
    return .failure(GeneratorError.badFormatURL)
  }
  let owner = repositoryURL.pathComponents[1]

  var name = repositoryURL.pathComponents[2]
  if name.hasSuffix(".git") {
    name = repositoryURL.deletingPathExtension().lastPathComponent
  }
  return .success((owner: owner, name: name))
}

public final class Generator {
  private let arguments: [String]
  private let network: Network

  public init(githubAccessToken: String = "", arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
    self.network = Network(accessToken: githubAccessToken)
  }

  func fetchPackage(publisher: PassthroughSubject<PackageLicense, Never>, packages: [Package]) {
    packages.forEach { (package) in
      guard
        case .success((owner: let owner, name: let name)) = parseRepositoryURL(
          repositoryURL: package.repositoryURL)
      else {
        publisher.send(
          PackageLicense(package: package, license: nil, licenseInfo: .failure(GeneratorError.badFormatURL)))
        return
      }
      self.network.getRepositoryLicenseConditions(owner: owner, name: name) { result in
        switch result {
        case .success(let repository):
          // TODO: Apache License needs to fetch NOTICE to print copyright of library.
          // (LICENSE file of Apache License does not contain copyright itself)
          if let licenseFile = repository.files.first(where: { $0 == "LICENSE" || $0.hasPrefix("LICENSE.") || $0 == "COPYING" }) {
            debugPrint("Fetch \(licenseFile) from \(owner)/\(name)")
            self.network.getContent(owner: owner, name: name, expression: "HEAD:\(licenseFile)") { result in
              switch result {
              case .success(let text):
                publisher.send(PackageLicense(package: package, license: text, licenseInfo: .success(repository.licenseInfo)))
              case .failure(let error):
                publisher.send(PackageLicense(package: package, license: nil, licenseInfo: .failure(error)))
              }
            }
          } else {
            debugPrint("License file is not found in \(owner)/\(name)")
            publisher.send(PackageLicense(package: package, license: nil, licenseInfo: .success(repository.licenseInfo)))
          }
        case .failure(let error):
          publisher.send(PackageLicense(package: package, license: nil, licenseInfo: .failure(error)))
        }
      }
    }
  }

  func packagesFromXcodeproj(xcodeProjFilePath: String) throws -> [Package] {
    let xcodeproj = try XcodeProj(pathString: xcodeProjFilePath)
    guard let packages = try xcodeproj.pbxproj.rootProject()?.packages else {
      print("There is no packages", to: &stderr)
      return []
    }
    return packages.compactMap { package in
      if let name = package.name, let repositoryURL = package.repositoryURL {
        return Package(name: name, repositoryURL: URL(string: repositoryURL)!)
      } else {
        return nil
      }
    }
  }

  func packagesFromPackageResolved(resolvedFilePath: String) throws -> [Package] {
    let decoder = JSONDecoder()
    let data = try Data(contentsOf: URL(fileURLWithPath: resolvedFilePath))
    let resolved = try decoder.decode(ResolvedFileJSON.self, from: data)
    return resolved.object.pins.map {
      Package(name: $0.package, repositoryURL: $0.repositoryURL)
    }
  }
  
  func shouldIncludeCopyright(licenseInfo: LicenseInfo) -> Bool {
    return licenseInfo.conditions.contains { $0.key == "include-copyright" }
  }
  
  func exportToFile(packageLicenses: [PackageLicense], outputFilePath: String, exportFormat: ExportFormat) throws {
    if case .json = exportFormat {
      let encoder = JSONEncoder()
      if let encoded = try? encoder.encode(packageLicenses) {
        try encoded.write(to: URL(fileURLWithPath: outputFilePath))
      }
    } else if case .rtf = exportFormat {
      let attributedString = NSMutableAttributedString()
      let fontSize: CGFloat = 12
      packageLicenses.forEach { (packageLicense) in
        let licenseNameAttributes: [NSAttributedString.Key: Any] = [.link: packageLicense.package.repositoryURL, .font: NSFont.boldSystemFont(ofSize: fontSize)]
        attributedString.append(NSAttributedString(string: "\(packageLicense.package.name)\n\n", attributes: licenseNameAttributes))
        let licenseBodyAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: fontSize)]
        if case .success(_) = packageLicense.licenseInfo {
          attributedString.append(NSAttributedString(string: "\(packageLicense.license ?? "---- No license file found in repository ----")\n\n", attributes: licenseBodyAttributes))
        } else {
          attributedString.append(NSAttributedString(string: "---- Failed to fetch license information ----\n\n", attributes: licenseBodyAttributes))
        }
      }
      let documentAttributes: [NSAttributedString.DocumentAttributeKey : Any] = [
        .comment: "This document is generated by SwiftPMLibraryLicenseGenerator (https://github.com/mtgto/SwiftPMLibraryLicenseGenerator)"
      ]
      if let data = attributedString.rtf(from: NSMakeRange(0, attributedString.length), documentAttributes: documentAttributes) {
        try data.write(to: URL(fileURLWithPath: outputFilePath))
      }
    }
  }
  
  public func exportTest(projectFilePath: String, outputFilePath: String, exportFormat: ExportFormat) throws {
    let packageLicenses: [PackageLicense] = [
      PackageLicense(package: Package(name: "hogehoge", repositoryURL: URL(string: "https://example.com")!), license: nil, licenseInfo: .failure(GeneratorError.badFormatURL))
    ]
    try self.exportToFile(packageLicenses: packageLicenses, outputFilePath: outputFilePath, exportFormat: exportFormat)
  }

  /**
   * @param projectFilePath Path of Package.swift or YourProject.xcodeproj
   * @param outputFilePath Path of export file
   */
  public func run(projectFilePath: String, outputFilePath: String, exportFormat: ExportFormat) throws {
    let packages: [Package]
    if projectFilePath.hasSuffix(".xcodeproj") {
      packages = try self.packagesFromXcodeproj(xcodeProjFilePath: projectFilePath)
    } else if projectFilePath.hasSuffix("Package.resolved") {
      packages = try self.packagesFromPackageResolved(resolvedFilePath: projectFilePath)
    } else {
      print("There is no packages", to: &stderr)
      exit(EXIT_SUCCESS)
    }

    print("There are \(packages.count) packages", to: &stderr)

    var subscriptions = Set<AnyCancellable>()

    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()

    let publisher = PassthroughSubject<PackageLicense, Never>()
    publisher
      .collect(packages.count)
      .sink(receiveValue: { packageLicenses in
        try? self.exportToFile(packageLicenses: packageLicenses, outputFilePath: outputFilePath, exportFormat: exportFormat)
        dispatchGroup.leave()
      }).store(in: &subscriptions)

    self.fetchPackage(publisher: publisher, packages: packages)

    dispatchGroup.notify(queue: .main) {
      print("Done", to: &stderr)
      exit(EXIT_SUCCESS)
    }

    // Run GCD main dispatcher, this function never returns, call exit() elsewhere to quit the program or it will hang
    dispatchMain()
  }
}
