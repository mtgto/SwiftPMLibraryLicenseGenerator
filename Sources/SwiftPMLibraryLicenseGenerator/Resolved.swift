import Foundation

// Structure of project.xcworkspace/xcshareddata/swiftpm/Package.resolved (JSON)
struct ResolvedFileJSON: Decodable {
  let object: Pins
  let version: UInt
}

struct Pins: Decodable {
  let pins: [Package]
}

struct Package: Decodable {
  let package: String
  let repositoryURL: URL
  let state: PackageState
}

struct PackageState: Decodable {
  let branch: String?
  let revision: String
  let version: String
}
