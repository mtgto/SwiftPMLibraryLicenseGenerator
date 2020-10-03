# SwiftPMLibraryLicenseGenerator

Generate licenses information of Xcode project file which uses Swift Package Manager in Xcode.

The pbxproj of this project generates these JSON:

```json

```

**IMPORTANT: Currently, this application has a large limitation.**

- When your project uses package A, and package A uses package B, this application prints only package A.

# Usage

Prepare GitHub private token to fetch license information by using GitHub GraphQL API.

```console
$ GITHUB_TOKEN=xxxxxxx SwiftPMLibraryLicenseGenerator /path/to/YourProject.pbxproj
```

# Limitation

- This application is only run macOS 10.15 or later.
- Supports github packages only.

# Related

- [LicensePlist](https://github.com/mono0926/LicensePlist)
  - It supports CocoaPods and Carthage, but does not support Swift PM yet.

# Development

GraphQL schema of GitHub is copied from
https://github.com/octokit/graphql-schema/blob/master/schema.json

# License

MIT License

# Author

[@mtgto](https://twitter.com/mtgto)
