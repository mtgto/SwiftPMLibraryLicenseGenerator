all:
	swift build
run:
	swift run SwiftPMLibraryLicenseGenerator ./SwiftPMLibraryLicenseGenerator.xcodeproj -o license.json
test:
	swift test
