/*
 * Usage:
 * $ GITHUB_TOKEN=xxxxxx ./this-binary /path/to/YourProject.pbxproj
 */

import Foundation
import SwiftPMLibraryLicenseGeneratorCore

do {
  try Generator().run()
} catch {
  exit(EXIT_FAILURE)
}
