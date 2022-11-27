//
//  NodeImage.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

func make_image(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    guard let args = get_args(env!, info!) else { return nil }
    guard args.count == 1 else { return nil }
    guard let arg0 = args[0] as? String else { return nil }
    let this = ImageContent(path: arg0)
    return as_value(env, this)
}
