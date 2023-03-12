//
//  NodeMap.swift
//  Texel
//
//  Created by Phillip Gerhardt on 11.03.23.
//

import Foundation

func make_map(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    var result: napi_value?
    guard let args = get_args(env!, info!) else { return nil }
    guard args.count == 1 else { return nil }
    guard let arg0 = as_simd(args[0]) as? simd_float2 else { return nil }

    var this: MapContent?

    DispatchQueue.main.sync {
        do {
            this = try MapContent(size: simd_int2(Int32(arg0.x), Int32(arg0.y)))
        } catch {
        }
    }

    if let this = this {
        result = as_value(env, this)
    }

    return result
}
