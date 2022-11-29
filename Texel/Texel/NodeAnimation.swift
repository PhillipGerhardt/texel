//
//  NodeAnimation.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

func make_animation(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    guard let args = get_args(env, info), args.count >= 1 else { return nil }

    var dur: Float?
    if args.count >= 2,
       let val = args[1] as? Float {
        dur = val
    }

    var ease: String?
    if args.count >= 3,
       let val = args[2] as? String {
        ease = val
    }

    if let t = as_simd(args[0]) as? Float { return wrap(env!, Animation(t, dur, ease)) }
    if let t = as_simd(args[0]) as? simd_float2 { return wrap(env!, Animation(t, dur, ease)) }
    if let t = as_simd(args[0]) as? simd_float3 { return wrap(env!, Animation(t, dur, ease)) }
    if let t = as_simd(args[0]) as? simd_float4 { return wrap(env!, Animation(t, dur, ease)) }
    if let t = as_simd(args[0]) as? simd_quatf { return wrap(env!, Animation(t, dur, ease)) }

    return nil
}
