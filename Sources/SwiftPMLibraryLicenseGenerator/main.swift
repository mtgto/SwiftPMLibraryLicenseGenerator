import Foundation
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

packages.forEach { package in
  print(package.versionRequirement)
}

func showUsage() {
  print("Usage: \(CommandLine.arguments[0]) /path/to/YourProject.pbxproj", to:&stderr)
}
