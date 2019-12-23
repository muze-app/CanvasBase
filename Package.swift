// swift-tools-version:5.1

import PackageDescription

let package = Package(
    
    name: "canvas-base",
    
    products: [
        .library( name: "canvas-base",
                  targets: ["canvas-base"]),
    ],
    
    dependencies: [],
    
    targets: [
        .target(name: "muze-prelude",
                dependencies: []),
        
        .target(name: "DAG",
                dependencies: ["muze-prelude"]),
        
        .target(name: "CanvasDAG",
                dependencies: ["DAG"]),
        
        .target( name: "canvas-base",
                 dependencies: ["CanvasDAG"]),
        
        .testTarget( name: "canvas-baseTests",
                     dependencies: ["canvas-base"]),
    ]
    
)

