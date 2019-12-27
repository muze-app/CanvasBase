// swift-tools-version:5.1

import PackageDescription

let package = Package(
    
    name: "CanvasBase",
    platforms: [.iOS(.v12), .macOS(.v10_14)],
    
    products: [
        .library( name: "CanvasBase",
                  targets: ["CanvasBase"])
//        .executable(name: "RunAndPlay", targets: ["RunAndPlay"])
    ],
    
    dependencies: [],
    
    targets: [
        .target(name: "MuzePrelude",
                dependencies: []),
        
        .target(name: "MuzeMetal",
                dependencies: []),
        
        .target(name: "DAG",
                dependencies: ["MuzePrelude"]),
        
        .target(name: "CanvasDAG",
                dependencies: ["DAG", "MuzeMetal"]),
        
        .target( name: "CanvasBase",
                 dependencies: ["CanvasDAG"]),
        
        .testTarget( name: "CanvasBaseTests",
                     dependencies: ["CanvasBase"])
        
//        .target(name: "RunAndPlay", dependencies: ["CanvasBase"])
    ],
    
    swiftLanguageVersions: [.v5]
    
)
