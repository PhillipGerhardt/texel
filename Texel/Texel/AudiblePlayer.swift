//
//  AudiblePlayer.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import AVFoundation

class AudibleSystem {
    let semaphore = DispatchSemaphore(value: 1)
    let audioEngine = AVAudioEngine()
    let playerNode = AVAudioPlayerNode()
    init() {
        /* Need something attached else it will not start. Just attach one playernode that does nothing. */
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
        try? audioEngine.start()
    }
}

let audibleSystem = AudibleSystem()

class AudiblePlayer {

    var playerNode: AVAudioPlayerNode?
    var mixerNode: AVAudioMixerNode?
    var volume: Float = 1 {
        didSet {
            mixerNode?.volume = volume
        }
    }

    deinit {
        if let mixerNode = mixerNode {
            audibleSystem.audioEngine.detach(mixerNode)
        }
        if let playerNode = playerNode {
            playerNode.stop()
            audibleSystem.audioEngine.detach(playerNode)
        }
    }

    func receive(_ sampleBuffer: CMSampleBuffer) {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
        let numSamples = CMSampleBufferGetNumSamples(sampleBuffer)
        let audioFormat = AVAudioFormat(cmAudioFormatDescription: formatDescription)
        let frameCapacity = AVAudioFrameCount(numSamples)
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCapacity) else { return }
        pcmBuffer.frameLength = frameCapacity
        let mutableAudioBufferList = pcmBuffer.mutableAudioBufferList
        CMSampleBufferCopyPCMDataIntoAudioBufferList(sampleBuffer, at: 0, frameCount: Int32(numSamples), into: mutableAudioBufferList)
        if playerNode == nil {
            /** When starting multiple videos almost simultaneously i got crashes when adding nodes
                to the audiosystem. This fixed it for me. */
            _ = audibleSystem.semaphore.wait(timeout: .distantFuture)
            defer { audibleSystem.semaphore.signal() }

            print("audioFormat", audioFormat)

            let node = AVAudioPlayerNode()
            let mixer = AVAudioMixerNode()
            mixer.volume = volume
            audibleSystem.audioEngine.attach(node)
            audibleSystem.audioEngine.attach(mixer)
            /* Our Mixernode will take care of any audio conversion. */
            audibleSystem.audioEngine.connect(mixer, to: audibleSystem.audioEngine.mainMixerNode, format: audioFormat)
            audibleSystem.audioEngine.connect(node, to: mixer, format: audioFormat)
            node.play()
            mixerNode = mixer
            playerNode = node
        }
        playerNode?.scheduleBuffer(pcmBuffer, at: nil, options: [], completionCallbackType: .dataPlayedBack, completionHandler: { _ in
//            print("done")
        })
    }

    func receive(_ sample: FFFrame) {
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sample.frame.pointee.sample_rate), channels: AVAudioChannelCount(sample.frame.pointee.channels)) else {
            print("error: AVAudioFormat")
            return
        }

//        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sample.frame.pointee.sample_rate), channelLayout: AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_MPEG_5_1_A)!)

        let frameCapacity = AVAudioFrameCount(sample.frame.pointee.nb_samples)
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCapacity) else { return }
        pcmBuffer.frameLength = frameCapacity

        let buffers = UnsafeMutableAudioBufferListPointer(pcmBuffer.mutableAudioBufferList)

        switch sample.frame.pointee.channels {
        case 8:
            buffers[7].mData?.copyMemory(from: sample.frame.pointee.data.7!, byteCount: Int(frameCapacity*4))
            fallthrough
        case 7:
            buffers[6].mData?.copyMemory(from: sample.frame.pointee.data.6!, byteCount: Int(frameCapacity*4))
            fallthrough
        case 6:
            buffers[5].mData?.copyMemory(from: sample.frame.pointee.data.5!, byteCount: Int(frameCapacity*4))
            fallthrough
        case 5:
            buffers[4].mData?.copyMemory(from: sample.frame.pointee.data.4!, byteCount: Int(frameCapacity*4))
            fallthrough
        case 4:
            buffers[3].mData?.copyMemory(from: sample.frame.pointee.data.3!, byteCount: Int(frameCapacity*4))
            fallthrough
        case 3:
            buffers[2].mData?.copyMemory(from: sample.frame.pointee.data.2!, byteCount: Int(frameCapacity*4))
            fallthrough
        case 2:
            buffers[1].mData?.copyMemory(from: sample.frame.pointee.data.1!, byteCount: Int(frameCapacity*4))
            fallthrough
        case 1:
            buffers[0].mData?.copyMemory(from: sample.frame.pointee.data.0!, byteCount: Int(frameCapacity*4))
            fallthrough
        default:
            break
        }

        if playerNode == nil {
            _ = audibleSystem.semaphore.wait(timeout: .distantFuture)
            defer { audibleSystem.semaphore.signal() }
            print("audioFormat", audioFormat)

            let node = AVAudioPlayerNode()
            let mixer = AVAudioMixerNode()
            audibleSystem.audioEngine.attach(node)
            audibleSystem.audioEngine.attach(mixer)
            audibleSystem.audioEngine.connect(mixer, to: audibleSystem.audioEngine.mainMixerNode, format: audioFormat)
            audibleSystem.audioEngine.connect(node, to: mixer, format: audioFormat)
            node.play()
            mixerNode = mixer
            playerNode = node
        }
        playerNode?.scheduleBuffer(pcmBuffer, at: nil, options: [], completionCallbackType: .dataPlayedBack, completionHandler: { _ in
        })

    }

}

