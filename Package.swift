// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DarkMagic",
	products: [
		.library(name: "DarkMagic", targets: ["DarkMagic"])
	],
	dependencies: [],
	targets: [
	.target(name: "DarkMagic", dependencies: [], path: "Sources/Shared"),
		.testTarget(name: "DarkMagicTests", dependencies: ["DarkMagic"], path: "DarkMagicTests/Shared")
	]
)
