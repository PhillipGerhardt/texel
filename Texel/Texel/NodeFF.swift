//
//  NodeFF.swift
//  Texel
//
//  Created by Phillip Gerhardt on 09.04.23.
//

func make_ff(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    do {
        guard let args = get_args(env!, info!) else { return nil }
        guard args.count >= 1 else { return nil }
        guard let arg0 = args[0] as? String else { return nil }
        var arg1: Bool?
        if args.count >= 2 { arg1 = args[1] as? Bool }
        var arg2: Bool?
        if args.count >= 3 { arg2 = args[2] as? Bool }
        let this = try FFContent(url: arg0, loop: arg1, mute: arg2)
        return as_value(env, this)
    }
    catch {
        napi_throw_error(env, nil, "make_ff \(error)")
        return nil
    }
}
