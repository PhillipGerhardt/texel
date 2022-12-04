//
//  NodeTicker.swift
//  Texel
//
//  Created by Phillip Gerhardt on 04.12.22.
//

import Foundation

let ticker_descriptors: [napi_property_descriptor] = [] + content_descriptors

func make_ticker(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    do {
        guard let args = get_args(env!, info!) else { return nil }
        guard args.count >= 2 else { return nil }
        guard let arg0 = as_simd(args[0]) as? simd_float2 else { return nil }
        guard let arg1 = args[1] as? String else { return nil }

        var arg2: Int?
        var arg3: Float?
        var arg4: simd_float4?
        var arg5: simd_float4?

        if args.count > 2 {
            guard let arg = args[2] as? Float else { return nil }
            arg2 = Int(arg)
        }
        if args.count > 3 {
            guard let arg = args[3] as? Float else { return nil }
            arg3 = arg
        }
        if args.count > 4 {
            guard let arg = as_simd(args[4]) as? simd_float4 else { return nil }
            arg4 = arg
        }
        if args.count > 5 {
            guard let arg = as_simd(args[5]) as? simd_float4 else { return nil }
            arg5 = arg
        }

        let this = try TickerContent(size: simd_int2(Int32(arg0.x), Int32(arg0.y)), text: arg1, speed: arg2, fontSize: arg3, foregroundColor: arg4, backgroundColor: arg5)
        return as_value(env, this)
    }
    catch {
        napi_throw_error(env, nil, "make_ticker \(error)")
        return nil
    }
}
