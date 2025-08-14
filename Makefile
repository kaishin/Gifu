test-ios:
	set -o pipefail && \
	xcodebuild test \
		-project Gifu.xcodeproj \
		-scheme Gifu \
		-destination "platform=iOS Simulator,name=iPhone 16,OS=18.2" \
		| xcbeautify

test-tvos:
	set -o pipefail && \
	xcodebuild test \
		-project Gifu.xcodeproj \
		-scheme Gifu \
		-destination "platform=tvOS Simulator,name=Apple TV" \
		| xcbeautify
