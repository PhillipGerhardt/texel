//
//  NodeRaw.swift
//  Texel
//
//  Created by Phillip Gerhardt on 19.02.23.
//

func make_raw(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    guard let args = get_args(env!, info!) else { return nil }
    guard args.count == 4 else { return nil }
    guard let arg0 = args[0] as? String else { return nil }
    guard let arg1 = args[1] as? Float else { return nil }
    guard let arg2 = args[2] as? Float else { return nil }
    guard let arg3 = args[3] as? Float else { return nil }
    let this = RawContent(path: arg0, width: Int(arg1), height: Int(arg2), bytesPerPixel: Int(arg3))
    return as_value(env, this)
}
