//
//  NodeVisionDetector.swift
//  Texel
//
//  Created by Phillip Gerhardt on 10.12.22.
//

func make_vision_detector(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    do {
        guard let args = get_args(env!, info!) else { return nil }
        guard args.count == 3 else { return nil }
        guard let arg0 = args[0] as? String else { return nil }
        guard let arg = args[1] as? String, let arg1 =  DetectionType(rawValue: arg) else { return nil }
        guard let arg2 = as_simd(args[2]) as? simd_float2 else { return nil }
        let this = try VisionDetectorContent(path: arg0, type: arg1, size: simd_int2(Int32(arg2.x), Int32(arg2.y)))
        return as_value(env, this)
    } catch {
        napi_throw_error(env, nil, "make_vision_detector \(error)")
        return nil
    }
}

