//
//  NodeAnimation.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

let animation_descriptors: [napi_property_descriptor] = [
    napi_property_descriptor(utf8name: strdup("cancel"), name: nil, method: animation_cancel, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
]

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

    var this: Animation?

    if let t = as_simd(args[0]) as? Float { this = Animation(t, dur, ease) }
    if let t = as_simd(args[0]) as? simd_float2 { this = Animation(t, dur, ease)  }
    if let t = as_simd(args[0]) as? simd_float3 { this = Animation(t, dur, ease) }
    if let t = as_simd(args[0]) as? simd_float4 { this = Animation(t, dur, ease)  }
    if let t = as_simd(args[0]) as? simd_quatf { this = Animation(t, dur, ease)  }

    if let this {
        return as_value(env, this)
    }

    return nil
}

// MARK - cancel

func animation_cancel(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? Animation else { return nil }
    this.cancel()
    return nil
}

