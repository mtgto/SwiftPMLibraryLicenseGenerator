import ArgumentParser
import Combine
import Foundation
import XcodeProj

enum GeneratorError: Error {
  case unsupportedHost, badFormatURL
}

// The result of fetch
struct PackageLicense: Encodable {
  let package: XCRemoteSwiftPackageReference
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
        try container.encode("repository URL of package has bad format or does not exists", forKey: .error)
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

  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
    guard let accessToken = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] else {
      print("Error: env GITHUB_TOKEN is not set", to: &stderr)
      exit(EXIT_FAILURE)
    }

    self.network = Network(accessToken: accessToken)
  }

  func generatePublisher(packages: [XCRemoteSwiftPackageReference]) -> AnyPublisher<PackageLicense, Never> {
    let publisher = PassthroughSubject<PackageLicense, Never>()
    packages.forEach { (package) in
      guard let repositoryURLString = package.repositoryURL else {
        print("Skip package \(package.name ?? "??") which has no repository URL", to: &stderr)
        publisher.send(PackageLicense(package: package, licenseInfo: .failure(GeneratorError.badFormatURL)))
        return
      }
      guard let repositoryURL = URL(string: repositoryURLString) else {
        print(
          "Skip package \(package.name ?? "??") which has invalid URL: \(repositoryURLString)",
          to: &stderr)
        publisher.send(PackageLicense(package: package, licenseInfo: .failure(GeneratorError.badFormatURL)))
        return
      }
      guard
        case .success((owner: let owner, name: let name)) = parseRepositoryURL(
          repositoryURL: repositoryURL)
      else {
        publisher.send(PackageLicense(package: package, licenseInfo: .failure(GeneratorError.badFormatURL)))
        return
      }
      self.network.getRepositoryLicenseConditions(owner: owner, name: name) { result in
        switch result {
        case .success(let licenseInfo):
          publisher.send(PackageLicense(package: package, licenseInfo: .success(licenseInfo)))
          return
        case .failure(let error):
          publisher.send(PackageLicense(package: package, licenseInfo: .failure(error)))
          return
        }
      }
    }
    return publisher.eraseToAnyPublisher()
  }

  public func run(xcodeProjFilePath: String, outputFilePath: String) throws {
    let xcodeproj = try XcodeProj(pathString: xcodeProjFilePath)
    guard let packages = try xcodeproj.pbxproj.rootProject()?.packages else {
      print("There is no packages", to: &stderr)
      exit(EXIT_SUCCESS)
    }
    
    print("There are \(packages.count) packages", to: &stderr)

    let publisher = self.generatePublisher(packages: packages)
    var subscriptions = Set<AnyCancellable>()

    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    
    publisher.collect(packages.count)
      .sink(receiveValue: { packageLicenses in
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(packageLicenses) {
          try? encoded.write(to: URL(fileURLWithPath: outputFilePath))
        }
//        print(packageLicenses)
        dispatchGroup.leave()
      }).store(in: &subscriptions)

    dispatchGroup.notify(queue: .main) {
      print("Done", to: &stderr)
      exit(EXIT_SUCCESS)
    }

    // Run GCD main dispatcher, this function never returns, call exit() elsewhere to quit the program or it will hang
    dispatchMain()
  }
}
