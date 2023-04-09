//
//  FFConverter.swift
//  Texel
//
//  Created by Phillip Gerhardt on 09.04.23.
//

/**
 * Convert audio samples
 */
class FFConverter {
    var context: OpaquePointer?

    init(_ sample: FFFrame) throws {

        let channel_layout = FFmpeg_AV_CH_LAYOUT_STEREO()

        guard let context = swr_alloc_set_opts(nil,
                                               channel_layout, // Int64(sample.frame.pointee.channel_layout),
                                               AV_SAMPLE_FMT_FLTP,
                                               sample.frame.pointee.sample_rate,
                                               Int64(sample.frame.pointee.channel_layout),
                                               AVSampleFormat.init(rawValue: sample.frame.pointee.format),
                                               sample.frame.pointee.sample_rate,
                                               0, nil) else {
            throw Fehler.swr_alloc_set_opts
        }
        self.context = context
        guard 0 == swr_init(self.context) else {
            throw Fehler.swr_init
        }
    }

    deinit {
        swr_free(&context)
    }

    func convert(_ sample: FFFrame) -> FFFrame {
        let out = FFFrame()

//        out.frame.pointee.channels = sample.frame.pointee.channels
//        out.frame.pointee.channel_layout = sample.frame.pointee.channel_layout

        let channel_layout = FFmpeg_AV_CH_LAYOUT_STEREO()

        out.frame.pointee.channels = 2
        out.frame.pointee.channel_layout = UInt64(channel_layout)

        out.frame.pointee.sample_rate = sample.frame.pointee.sample_rate
        out.frame.pointee.format = AV_SAMPLE_FMT_FLTP.rawValue

        swr_convert_frame(context, out.frame, sample.frame)
        return out
    }

}

