//
//  FFSample.swift
//  Texel
//
//  Created by Phillip Gerhardt on 09.04.23.
//

import Foundation

class FFFrame {
    var codec_type: AVMediaType = AVMEDIA_TYPE_UNKNOWN
    var pts: CFTimeInterval = 0
    var frame: UnsafeMutablePointer<AVFrame>!

    init() {
        frame = av_frame_alloc()
    }

    deinit {
        av_frame_free(&frame)
    }
}
