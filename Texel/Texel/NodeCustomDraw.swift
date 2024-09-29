//
//  NodeCustomDraw.swift
//  Texel
//
//  Created by Phillip Gerhardt on 2024.09.28.
//

import Foundation

let customDraw_descriptors: [napi_property_descriptor] = [] + content_descriptors

func make_customDraw(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    do {
        guard let args = get_args(env!, info!) else { return nil }
        guard args.count == 3 else { return nil }
        guard let arg0 = args[0] as? Float else { return nil }
        guard let arg1 = args[1] as? Float else { return nil }
        guard let arg2 = args[2] as? Float else { return nil }

        let this = try CustomDrawContent(numSamples: Int(arg0), speed: arg1, pointSize: arg2)
        return as_value(env, this)
    } catch {
        napi_throw_error(env, nil, "make_customDraw \(error)")
        return nil
    }
}
