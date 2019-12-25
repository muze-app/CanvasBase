//
//  VideoNode.swift
//  muze
//
//  Created by Greg Fajen on 7/9/19.
//  Copyright © 2019 Ergo Sum. All rights reserved.
//

import UIKit
import AVKit

struct AVTime: Comparable {
    
    let numerator: Int
    static var denominator: Int { return 2998 * 44100 }
    var denominator: Int { return AVTime.denominator }
    
    init(numerator: Int) {
        self.numerator = numerator
    }
    
    init(seconds: TimeInterval) {
        self.numerator = Int(round(seconds * TimeInterval(AVTime.denominator)))
    }
    
    init(samples: Int) {
        numerator = samples * 2998
    }
    
//    init(frames: Int) {
//        numerator = frames * 44100
//    }
    
    var seconds: TimeInterval {
        return TimeInterval(numerator) / TimeInterval(denominator)
    }
    
    static func < (lhs: AVTime, rhs: AVTime) -> Bool {
        return lhs.numerator < rhs.numerator
    }
    
    var samples: Int {
        return numerator / 2998
    }
    
//    var frames: Int {
//        return numerator / 44100
//    }
    
}

//class AbstractVideoProvider: Hashable, Equatable {
//    
//    static func == (lhs: AbstractVideoProvider, rhs: AbstractVideoProvider) -> Bool {
//        if let lhs = lhs as? CanvasVideoProvider, let rhs = rhs as? CanvasVideoProvider {
//            return lhs.url == rhs.url
//        } else {
//            return lhs === rhs
//        }
//    }
//    
//    
//    func tempGetNextTexture(time: TimeInterval) -> MetalTexture {
//        fatalError()
//    }
//    
//    func tempGetAudioSamples(_ range: Range<AVTime>) -> [Float32] {
//        fatalError()
//    }
//    
//    
//    func hash(into hasher: inout Hasher) {
//        if let self = self as? CanvasVideoProvider {
//            hasher.combine(self.url)
//        } else {
//            hasher.combine(pointerString)
//        }
//    }
//    
//    var pointerString: String {
//        let unsafe = Unmanaged.passUnretained(self).toOpaque()
//        return "\(unsafe)"
//    }
//    
//    var size: CGSize { return CGSize(width: 1080, height: 1920) }
//    
//    var duration: TimeInterval { return 0 }
//    
//}

//final class CanvasVideoProvider: AbstractVideoProvider {
//
//    let url: URL
//    let asset: AVAsset
//    var reader: AVAssetReader!
//    var videoOutput: AVAssetReaderTrackOutput?
//    var audioOutput: AVAssetReaderTrackOutput?
//
//    var hasVideo: Bool { return videoOutput.exists }
//    var hasAudio: Bool { return audioOutput.exists }
//
//    var currentVideoBuffer: CMSampleBuffer?
//    var currentTexture: MetalTexture?
//
//    var currentAudioBuffer: CMSampleBuffer?
//
//    init?(_ url: URL) {
//        self.url = url
//        asset = AVAsset(url: url)
//
//        super.init()
//
//        setupReader()
//    }
//
//    static func == (lhs: CanvasVideoProvider, rhs: CanvasVideoProvider) -> Bool {
//        return lhs.url == rhs.url
//    }
//
//    override func hash(into hasher: inout Hasher) {
//        hasher.combine(url)
//    }
//
//    override var size: CGSize { return CGSize(width: 1080, height: 1920) }
//
////    static var isFirst = true
//
//    func setupReader() {
//        currentVideoBuffer = nil
//        currentAudioBuffer = nil
//
//        reader = try! AVAssetReader(asset: asset)
//
//        if let videoTrack = asset.tracks(withMediaType: .video).first {
//            let videoSettings: [String:Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
//            videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoSettings)
//            reader.add(videoOutput!)
//        }
//
//        if let audioTrack = asset.tracks(withMediaType: .audio).first {
//        let audioSettings: [String:Any] = [AVFormatIDKey as String: kAudioFormatLinearPCM,
//                                           AVSampleRateKey: 44100,
//                                           AVNumberOfChannelsKey: 1,
//                                           AVLinearPCMBitDepthKey: 32,
//                                           AVLinearPCMIsFloatKey: true,
//                                           AVLinearPCMIsBigEndianKey: false]
//            audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioSettings)
//            reader.add(audioOutput!)
//        }
//
//        reader.startReading()
//    }
//
//    override func tempGetAudioSamples(_ range: Range<AVTime>) -> [Float32] {
//        guard let audioOutput = audioOutput else { return [] }
//
//        if !currentAudioBuffer.exists {
//            currentAudioBuffer = audioOutput.copyNextSampleBuffer()!
//        }
//
//        let presentation = currentAudioBuffer!.presentationTime
//        let duration = currentAudioBuffer!.duration
//
//        print("presentation: \(presentation)")
//        print("duration: \(duration)")
//
//        return []
//    }
//
//    override func tempGetNextTexture(time: TimeInterval) -> MetalTexture {
//        guard let videoOutput = videoOutput else { fatalError() }
//
//        let time = time.truncatingRemainder(dividingBy: duration)
//
//        let frameDuration: TimeInterval = 1.0 / 29.98
//
//
//        if let buffer = currentVideoBuffer,
//            let texture = currentTexture,
//            buffer.presentationTime <= time,
//            buffer.presentationTime + frameDuration >= time {
//
//            texture.timeStamp = buffer.presentationTime.seconds
//
//            let timeStamp = texture.timeStamp!
//            let diff = abs(time - timeStamp)
//            if diff > 0.3 {
//                print("wut...")
//            }
//
//            return texture
//        }
//
//        var next = videoOutput.copyNextSampleBuffer()
//        if !next.exists || (next?.presentationTime ?? .zero) > time {
//            setupReader()
//            next = videoOutput.copyNextSampleBuffer()
//        }
//
//        while let _next = next, _next.presentationTime + frameDuration <= time {
//            next = videoOutput.copyNextSampleBuffer()
//        }
//
//        currentVideoBuffer = next
//        currentTexture = MetalHeapManager.shared.makeTexture(from: next!.imageBuffer!, orientation: .up)!
//
//        currentTexture!.timeStamp = currentVideoBuffer!.presentationTime.seconds
//
//        let timeStamp = currentTexture!.timeStamp!
//        let diff = abs(time - timeStamp)
//        if diff > 0.3 {
//            print("wut...")
//        }
//
//        return currentTexture!
//    }
//
//    override var duration: TimeInterval { return asset.duration.seconds }
//
//
//
//}

//public struct VideoPayload: NodePayload {
//
//    var provider: AbstractVideoProvider
//    var transform: AffineTransform
//    var colorMatrix: DMatrix3x3
//
//    init(_ a: AbstractVideoProvider, _ b: AffineTransform = .identity, _ c: DMatrix3x3) {
//        self.provider = a
//        self.transform = b
//        self.colorMatrix = c
//    }
//
//    public func transformed(by transform: AffineTransform) -> VideoPayload {
//        return VideoPayload(provider, transform * transform, colorMatrix)
//    }
//
//}
//
//// these may get their own file as they get expanded upon
//final class VideoNode: GeneratorNode<VideoPayload> {
//
//    convenience init(_ provider: AbstractVideoProvider,
//                     _ transform: AffineTransform = .identity,
//                     _ colorMatrix: DMatrix3x3 = .identity) {
//        self.init(.init(provider, transform, colorMatrix))
//    }
//
//    override var nodeType: NodeType { return .video }
//
//    var provider: AbstractVideoProvider {
//        get { return payload.provider }
//        set { payload.provider = newValue }
//    }
//
//    var transform: AffineTransform {
//        get { return payload.transform }
//        set { payload.transform = newValue }
//    }
//
//    var colorMatrix: DMatrix3x3 {
//        get { return payload.colorMatrix }
//        set { payload.colorMatrix = newValue }
//    }
//
//    var colorMatrixIsIdentity: Bool {
//        return colorMatrix ~ DMatrix3x3.identity
//    }
//
//    override public func renderPayload(for options: RenderOptions) -> RenderPayload? {
//        let texture = provider.tempGetNextTexture(time: options.time)
//
//        let t: RenderPayload = .texture(texture)
//        let m: RenderPayload = colorMatrixIsIdentity ? t : .colorMatrix(t, colorMatrix)
//
//        return .cropAndTransform(m, provider.size, transform)
//    }
//
//    override var calculatedRenderExtent: RenderExtent {
//        return .basic(BasicExtent(size: provider.size, transform: transform))
//    }
//
//    override var userExtent: UserExtent {
//        return .photo & renderExtent
//    }
//
//    override var cacheable: Bool {
//        return false
//    }
//
//    var duration: TimeInterval { return provider.duration }
//
//}

public func <= (l: CMTime, r: TimeInterval) -> Bool {
    let l = l.seconds
    return l <= r
}

public func >= (l: CMTime, r: TimeInterval) -> Bool {
    let l = l.seconds
    return l >= r
}

public func < (l: CMTime, r: TimeInterval) -> Bool {
    let l = l.seconds
    return l < r
}

public func > (l: CMTime, r: TimeInterval) -> Bool {
    let l = l.seconds
    return l > r
}

extension CMTime: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: TimeInterval) {
        self = CMTime(seconds: value, preferredTimescale: 1)
    }
    
}

extension CMTime: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "\(seconds)"
    }
    
}

func + (l: CMTime, r: TimeInterval) -> TimeInterval {
    return l.seconds + r
}
