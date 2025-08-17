# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.1] - 2024-08-17

### Fixed

- Fixed `Gifu.podspec` by removing invalid Swift 6.2 reference and cleaning up submodules configuration
- Improved compatibility with dependency managers

## [4.0.0] - 2024-08-16

### Added

- Full Swift 6 support with strict concurrency enabled
- Swift 6.0-specific package configuration (`Package@swift-6.0.swift`)
- Enabled `ExistentialAny` upcoming feature for better type safety
- Enhanced Swift Testing framework integration

### Changed

- Migrated test suite from XCTest to Swift Testing framework
- Updated project build settings for Swift 6 compatibility
- Updated GitHub Actions workflow for Swift 6 testing
- Performance optimizations for animations and frame handling
