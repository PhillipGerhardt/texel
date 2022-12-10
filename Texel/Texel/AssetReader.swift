//
//  AssetReader.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import AVFoundation

class AssetReader {
    var reader: AVAssetReader
    var visualOutput: AVAssetReaderTrackOutput?
    var audibleOutput: AVAssetReaderTrackOutput?

    var naturalSize: simd_int2 { get {
        if let visualOutput {
            let w = Int32(visualOutput.track.naturalSize.width)
            let h = Int32(visualOutput.track.naturalSize.height)
            return simd_int2(w, h)
        }
        return .zero
    } }

    var status: AVAssetReader.Status {
        get { reader.status }
    }

    init(asset: AVAsset, visualOutputSettings: [String : Any]?, audibleOutputSettings: [String : Any]?, timeRange: CMTimeRange?) throws {
        reader = try AVAssetReader(asset: asset)
        if let timeRange = timeRange {
            reader.timeRange = timeRange
        }

        if visualOutputSettings != nil,
           let visualTrack = asset.tracks.first(where: { track in track.hasMediaCharacteristic(.visual)}) {
            let visualOutput = AVAssetReaderTrackOutput(track: visualTrack, outputSettings: visualOutputSettings)
//            print(visualTrack.formatDescriptions)
            visualOutput.alwaysCopiesSampleData = false
            reader.add(visualOutput)
            self.visualOutput = visualOutput
        }

        if audibleOutputSettings != nil,
           let audibleTrack = asset.tracks.first(where: { track in track.hasMediaCharacteristic(.audible)}) {
            let audibleOutput = AVAssetReaderTrackOutput(track: audibleTrack, outputSettings: audibleOutputSettings)
            audibleOutput.alwaysCopiesSampleData = false
            reader.add(audibleOutput)
            self.audibleOutput = audibleOutput
        }
    }

    func startReading() {
        reader.startReading()
    }

    func cancelReading() {
        reader.cancelReading()
    }
}
