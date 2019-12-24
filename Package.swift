// swift-tools-version:5.1

import PackageDescription

let package = Package(
    
    name: "CanvasBase",
    platforms: [.iOS(.v12)],
    
    products: [
        .library( name: "CanvasBase",
                  targets: ["CanvasBase"])
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
    ]
    
)
