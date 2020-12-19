import Foundation

// Structure of project.xcworkspace/xcshareddata/swiftpm/Package.resolved (JSON)
struct ResolvedFileJSON: Decodable {
  let object: ResolvedFilePins
  let version: UInt
}

struct ResolvedFilePins: Decodable {
  let pins: [ResolvedFilePackage]
}

struct ResolvedFilePackage: Decodable {
  let package: String
  let repositoryURL: URL
  let state: ResolvedFilePackageState
}

struct ResolvedFilePackageState: Decodable {
  let branch: String?
  let revision: String
  let version: String?
}
