//
//  ffmpeg_interop.h
//  Texel
//
//  Created by Phillip Gerhardt on 09.04.23.
//

#pragma once

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswresample/swresample.h>

int64_t FFmpeg_AV_CH_LAYOUT_STEREO(void);
