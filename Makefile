all:
	swift build
xcodeproj:
	swift package generate-xcodeproj
run:
	swift run swift-pm-library-license-generator ./SwiftPMLibraryLicenseGenerator.xcodeproj -o license.json
test:
	swift test
