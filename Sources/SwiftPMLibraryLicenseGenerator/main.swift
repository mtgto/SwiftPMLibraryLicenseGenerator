/*
 * Usage:
 * $ GITHUB_TOKEN=xxxxxx ./this-binary /path/to/YourProject.pbxproj
 */

import Combine
import Foundation
import XcodeProj

enum GeneratorError: Error {
  case unsupportedPackage, unknown
}

func showUsage() {
  print("Usage: \(CommandLine.arguments[0]) /path/to/YourProject.pbxproj", to: &stderr)
}

public func parseRepositoryURL(repositoryURL: URL) -> Result<(owner: String, name: String), Error> {
  if repositoryURL.host?.lowercased() != "github.com" {
    print("Skip  \(repositoryURL) which does not have GitHub domain")
    return .failure(GeneratorError.unsupportedPackage)
  }
  if repositoryURL.pathComponents.count != 3 {
    print("Skip \(repositoryURL) which has invalid GitHub URL")
    return .failure(GeneratorError.unsupportedPackage)
  }
  let owner = repositoryURL.pathComponents[1]

  var name = repositoryURL.pathComponents[2]
  if name.hasSuffix(".git") {
    name = repositoryURL.deletingPathExtension().lastPathComponent
  }
  return .success((owner: owner, name: name))
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

if CommandLine.arguments.count < 2 {
  showUsage()
  exit(EXIT_FAILURE)
}

let xcodeproj = try XcodeProj(pathString: CommandLine.arguments[1])
let packages = try xcodeproj.pbxproj.rootProject()?.packages
guard let packages = packages else {
  print("There is no packages", to: &stderr)
  exit(EXIT_SUCCESS)
}

guard let accessToken = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] else {
  print("Error: env GITHUB_TOKEN is not set", to: &stderr)
  exit(EXIT_FAILURE)
}

let network = Network(accessToken: accessToken)

let licenseInfos = packages.map { package in
  Future<LicenseInfo, Error> { promise in
    guard let repositoryURLString = package.repositoryURL else {
      print("Skip package \(package.name ?? "??") which has no repository URL")
      return promise(.failure(GeneratorError.unsupportedPackage))
    }
    guard let repositoryURL = URL(string: repositoryURLString) else {
      print("Skip package \(package.name ?? "??") which has invalid URL: \(repositoryURLString)")
      return promise(.failure(GeneratorError.unsupportedPackage))
    }
    guard
      case .success((owner: let owner, name: let name)) = parseRepositoryURL(
        repositoryURL: repositoryURL)
    else {
      return promise(.failure(GeneratorError.unsupportedPackage))
    }
    network.getRepositoryLicenseConditions(owner: owner, name: name) { result in
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
      print(error)
    }
  }) { licenseInfos in
    print(licenseInfos)
    dispatchGroup.leave()
  }.store(in: &subscriptions)

dispatchGroup.notify(queue: .main) {
  print("Done", to: &stderr)
  exit(EXIT_SUCCESS)
}

// Run GCD main dispatcher, this function never returns, call exit() elsewhere to quit the program or it will hang
dispatchMain()
