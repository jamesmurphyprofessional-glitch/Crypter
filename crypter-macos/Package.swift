// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Crypter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "crypter",
            targets: ["Crypter"]
        )
    ],
    targets: [
        .executableTarget(
            name: "Crypter",
            dependencies: [],
            path: "Sources/Crypter",
            exclude: [
                "sample_payload.swift"
            ],
            sources: [
                "AESCrypter.swift",
                "CrypterMain.swift"
            ]
        )
    ]
)
