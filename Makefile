test-ios:
	set -o pipefail && \
	xcodebuild test \
		-project Gifu.xcodeproj \
		-scheme Gifu \
		-destination platform="iOS Simulator,name=iPhone 11,OS=13.1" \
		| xcpretty

test-tvos:
	set -o pipefail && \
	xcodebuild test \
		-project Gifu.xcodeproj \
		-scheme Gifu-tvOS \
		-destination platform="tvOS Simulator,name=Apple TV,OS=13.1" \
		| xcpretty
