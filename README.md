# SwiftPMLibraryLicenseGenerator

Generate licenses information of Xcode project file which uses Swift Package Manager in Xcode.

The pbxproj of this project generates these JSON:

<details>
<summary>Output Example</summary>

```json
[
  {
    "name": "Spectre",
    "repositoryURL": "https:\/\/github.com\/kylef\/Spectre.git",
    "licenseInfo": {
      "implementation": "Create a text file (typically named LICENSE or LICENSE.txt) in the root of your source code and copy the text of the license into the file. Replace [year] with the current year and [fullname] with the name (or names) of the copyright holders.",
      "body": "BSD 2-Clause License\n\nCopyright (c) [year], [fullname]\nAll rights reserved.\n\nRedistribution and use in source and binary forms, with or without\nmodification, are permitted provided that the following conditions are met:\n\n1. Redistributions of source code must retain the above copyright notice, this\n   list of conditions and the following disclaimer.\n\n2. Redistributions in binary form must reproduce the above copyright notice,\n   this list of conditions and the following disclaimer in the documentation\n   and\/or other materials provided with the distribution.\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\"\nAND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE\nIMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE\nDISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE\nFOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL\nDAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR\nSERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER\nCAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,\nOR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE\nOF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\n",
      "name": "BSD 2-Clause \"Simplified\" License",
      "conditions": [
        {
          "key": "include-copyright",
          "label": "License and copyright notice",
          "description": "A copy of the license and copyright notice must be included with the software."
        }
      ]
    }
  }
]
```
</details>

# Usage

First, prepare GitHub private token to fetch license information by using GitHub GraphQL API.
If you don't have a token, create in github setting page: https://github.com/settings/tokens



```console
# Recommend
$ GITHUB_TOKEN=xxxxxxx swift-pm-library-license-generator --json -o license.json /path/to/Package.resolved
$ GITHUB_TOKEN=xxxxxxx swift-pm-library-license-generator --rtf -o license.rtf /path/to/Package.resolved

# If you don't have Package.resolved:
$ GITHUB_TOKEN=xxxxxxx swift-pm-library-license-generator --json -o license.json /path/to/YourProject.pbxproj
$ GITHUB_TOKEN=xxxxxxx swift-pm-library-license-generator --rtf -o license.rtf /path/to/YourProject.pbxproj
```

# Limitation

- This application is only run macOS 10.15 or later.
- Supports github packages only.
- RTF format does not contains copyright notation for some licenses (Apache License, GPL, etc.)

# Related

- [LicensePlist](https://github.com/mono0926/LicensePlist)
  - It supports CocoaPods and Carthage, and also Swift PM.

# Development

GraphQL schema of GitHub is copied from
https://github.com/octokit/graphql-schema/blob/master/schema.json

# License

MIT License

# Author

[@mtgto](https://twitter.com/mtgto)
