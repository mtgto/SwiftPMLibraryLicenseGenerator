/*
 * Usage:
 * $ GITHUB_TOKEN=xxxxxx ./this-binary /path/to/YourProject.pbxproj
 */

import Foundation
import Combine
import XcodeProj

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
  exit(1)
}

let xcodeproj = try XcodeProj(pathString: CommandLine.arguments[1])
let packages = try xcodeproj.pbxproj.rootProject()?.packages
guard let packages = packages else {
  print("There is no packages", to:&stderr)
  exit(0)
}

guard let accessToken = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] else {
  print("Error: env GITHUB_TOKEN is not set", to:&stderr)
  exit(1)
}

let network = Network(accessToken: accessToken)

packages.forEach { package in
  guard let repositoryURLString = package.repositoryURL else {
    print("Skip package \(package.name ?? "??") which has no repository URL")
    return
  }
  guard let repositoryURL = URL(string: repositoryURLString) else {
    print("Skip package \(package.name ?? "??") which has invalid URL: \(repositoryURLString)")
    return
  }
  if repositoryURL.host?.lowercased() != "github.com" {
    print("Skip package \(package.name ?? "??") which is not github: \(repositoryURLString)")
    return
  }
  if repositoryURL.pathComponents.count < 2 {
    print("Skip package \(package.name ?? "??") which has invalid URL: \(repositoryURLString)")
    return
  }
  let owner = repositoryURL.pathComponents[0]
  let name = repositoryURL.pathComponents[1]
  network.getRepositoryLicenseConditions(owner: owner, name: name) { result in
    print(result)
  }
}

print("Done", to:&stderr)

func showUsage() {
  print("Usage: \(CommandLine.arguments[0]) /path/to/YourProject.pbxproj", to:&stderr)
}
