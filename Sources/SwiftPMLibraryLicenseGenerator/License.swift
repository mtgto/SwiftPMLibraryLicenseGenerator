import Foundation

// Structure of license information of GitHub GraphQL response. See *.graphql for details.
struct LicenseInfo: Codable {
  let name: String
  let implementation: String?
  let body: String
  let conditions: [LicenseRule]
}

struct LicenseRule: Codable {
  let key: String
  let label: String
  let description: String
}
