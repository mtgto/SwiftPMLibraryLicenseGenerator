import ArgumentParser
import Combine
import Foundation
import XcodeProj

enum GeneratorError: Error {
  case unsupportedPackage, unknown
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

func showUsage() {
  print("Usage: \(CommandLine.arguments[0]) /path/to/YourProject.pbxproj", to: &stderr)
}

func parseRepositoryURL(repositoryURL: URL) -> Result<(owner: String, name: String), Error> {
  if repositoryURL.host?.lowercased() != "github.com" {
    print("Skip  \(repositoryURL) which does not have GitHub domain", to: &stderr)
    return .failure(GeneratorError.unsupportedPackage)
  }
  if repositoryURL.pathComponents.count != 3 {
    print("Skip \(repositoryURL) which has invalid GitHub URL", to: &stderr)
    return .failure(GeneratorError.unsupportedPackage)
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

  func generatePublisher(packages: [XCRemoteSwiftPackageReference]) -> [Future<LicenseInfo, Error>]
  {
    let licenseInfos = packages.map { package in
      Future<LicenseInfo, Error> { promise in
        guard let repositoryURLString = package.repositoryURL else {
          print("Skip package \(package.name ?? "??") which has no repository URL", to: &stderr)
          return promise(.failure(GeneratorError.unsupportedPackage))
        }
        guard let repositoryURL = URL(string: repositoryURLString) else {
          print(
            "Skip package \(package.name ?? "??") which has invalid URL: \(repositoryURLString)",
            to: &stderr)
          return promise(.failure(GeneratorError.unsupportedPackage))
        }
        guard
          case .success((owner: let owner, name: let name)) = parseRepositoryURL(
            repositoryURL: repositoryURL)
        else {
          return promise(.failure(GeneratorError.unsupportedPackage))
        }
        self.network.getRepositoryLicenseConditions(owner: owner, name: name) { result in
          switch result {
          case .success(let licenseInfo):
            return promise(.success(licenseInfo))
          case .failure(let error):
            return promise(.failure(error))
          }
        }
      }
    }
    return licenseInfos
  }

  public func run(xcodeProjFilePath: String, outputFilePath: String) throws {
    let xcodeproj = try XcodeProj(pathString: xcodeProjFilePath)
    guard let packages = try xcodeproj.pbxproj.rootProject()?.packages else {
      print("There is no packages", to: &stderr)
      exit(EXIT_SUCCESS)
    }

    let licenseInfos = packages.map { package in
      Future<LicenseInfo, Error> { promise in
        guard let repositoryURLString = package.repositoryURL else {
          print("Skip package \(package.name ?? "??") which has no repository URL", to: &stderr)
          return promise(.failure(GeneratorError.unsupportedPackage))
        }
        guard let repositoryURL = URL(string: repositoryURLString) else {
          print(
            "Skip package \(package.name ?? "??") which has invalid URL: \(repositoryURLString)",
            to: &stderr)
          return promise(.failure(GeneratorError.unsupportedPackage))
        }
        guard
          case .success((owner: let owner, name: let name)) = parseRepositoryURL(
            repositoryURL: repositoryURL)
        else {
          return promise(.failure(GeneratorError.unsupportedPackage))
        }
        self.network.getRepositoryLicenseConditions(owner: owner, name: name) { result in
          switch result {
          case .success(let licenseInfo):
            return promise(.success(licenseInfo))
          case .failure(let error):
            return promise(.failure(error))
          }
        }
      }
    }

    print("There are \(packages.count) packages", to: &stderr)

    var subscriptions = Set<AnyCancellable>()

    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()

    Publishers.MergeMany(licenseInfos)
      .collect()
      .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
          print(error, to: &stderr)
        }
      }) { licenseInfos in
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(licenseInfos) {
          try? encoded.write(to: URL(fileURLWithPath: outputFilePath))
        }
        dispatchGroup.leave()
      }.store(in: &subscriptions)

    dispatchGroup.notify(queue: .main) {
      print("Done", to: &stderr)
      exit(EXIT_SUCCESS)
    }

    // Run GCD main dispatcher, this function never returns, call exit() elsewhere to quit the program or it will hang
    dispatchMain()
  }
}
