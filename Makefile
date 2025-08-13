test-ios-18:
	set -o pipefail && \
	swift test \
		--destination "platform=iOS Simulator,name=iPhone 16,OS=18.1"

test-ios-17:
	set -o pipefail && \
	swift test \
		--destination "platform=iOS Simulator,name=iPhone 15,OS=17.5"

test-tvos:
	set -o pipefail && \
	swift test \
		--destination "platform=tvOS Simulator,name=Apple TV"

# Legacy xcodebuild targets for compatibility
test-ios-18-xcode:
	set -o pipefail && \
	xcodebuild test \
		-project Gifu.xcodeproj \
		-scheme Gifu \
		-destination "platform=iOS Simulator,name=iPhone 16,OS=18.1" \
		| xcbeautify

test-ios-17-xcode:
	set -o pipefail && \
	xcodebuild test \
		-project Gifu.xcodeproj \
		-scheme Gifu \
		-destination "platform=iOS Simulator,name=iPhone 15,OS=17.5" \
		| xcbeautify

test-tvos-xcode:
	set -o pipefail && \
	xcodebuild test \
		-project Gifu.xcodeproj \
		-scheme Gifu \
		-destination "platform=tvOS Simulator,name=Apple TV" \
		| xcbeautify
