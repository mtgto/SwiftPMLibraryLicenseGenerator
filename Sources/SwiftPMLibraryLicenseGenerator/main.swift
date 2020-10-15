/*
 * Usage:
 * $ GITHUB_TOKEN=xxxxxx ./this-binary -o /path/to/exportfile /path/to/YourProject.pbxproj
 */

import ArgumentParser
import Foundation
import SwiftPMLibraryLicenseGeneratorCore

struct Options: ParsableArguments {
  @Flag(help: "Export as JSON")
  var json = false
  
  @Flag(help: "Export as RTF")
  var rtf = false
  
  @Option(
    name: .short,
    help: ArgumentHelp(
      "Output file", discussion: "The destination of output file", valueName: "outputFile"))
  var outputFilePath = ""

  @Argument(help: "Path of YourProject.xcodeproj or Package.swift") var projectFilePath: String = ""
}

let options = Options.parseOrExit()

do {
  let accessToken = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] ?? ""
  let exportFormat = options.rtf ? ExportFormat.rtf : ExportFormat.json
  try Generator(githubAccessToken: accessToken)
    //.exportTest(projectFilePath: options.projectFilePath, outputFilePath: options.outputFilePath, exportFormat: exportFormat)
    .run(projectFilePath: options.projectFilePath, outputFilePath: options.outputFilePath, exportFormat: exportFormat)
} catch {
  exit(EXIT_FAILURE)
}
