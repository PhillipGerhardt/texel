//
//  NodeGameOfLife.swift
//  Texel
//
//  Created by Phillip Gerhardt on 18.12.22.
//

func make_game_of_life(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    do {
        guard let args = get_args(env!, info!) else { return nil }
        guard args.count == 1 else { return nil }
        guard let arg0 = as_simd(args[0]) as? simd_float2 else { return nil }
        let this = try GameOfLifeContent(size: simd_int2(Int32(arg0.x), Int32(arg0.y)))
        return as_value(env, this)
    } catch {
        napi_throw_error(env, nil, "make_game_of_life \(error)")
        return nil
    }
}


