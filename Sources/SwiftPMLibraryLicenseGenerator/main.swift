/*
 * Usage:
 * $ GITHUB_TOKEN=xxxxxx ./this-binary /path/to/YourProject.pbxproj
 */

import ArgumentParser
import Foundation
import SwiftPMLibraryLicenseGeneratorCore

struct Options: ParsableArguments {
  @Option(
    name: .short,
    help: ArgumentHelp(
      "Output file", discussion: "The destination of output file (JSON)", valueName: "outputFile"))
  var outputFilePath = ""

  @Argument(help: "Path of YourProject.xcodeproj or Package.swift") var projectFilePath: String = ""
}

let options = Options.parseOrExit()

do {
  try Generator().run(
    projectFilePath: options.projectFilePath, outputFilePath: options.outputFilePath)
} catch {
  exit(EXIT_FAILURE)
}
