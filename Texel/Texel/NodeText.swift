//
//  NodeText.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

let text_descriptors: [napi_property_descriptor] = [
    napi_property_descriptor(utf8name: strdup("backgroundColor"), name: nil, method: nil, getter: get_text_backgroundColor, setter: set_text_backgroundColor, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("foregroundColor"), name: nil, method: nil, getter: get_text_foregroundColor, setter: set_text_foregroundColor, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("text"), name: nil, method: nil, getter: get_text_text, setter: set_text_text, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("textSize"), name: nil, method: nil, getter: get_text_textSize, setter: set_text_textSize, value: nil, attributes: napi_default_method, data: nil),
] + content_descriptors

func make_text(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    do {
        guard let args = get_args(env!, info!) else { return nil }
        guard args.count >= 1 else { return nil }
        guard let arg0 = args[0] as? String else { return nil }
        var arg1 = simd_int2(256, 256)
        if args.count >= 2, let arg = as_simd(args[1]) as? simd_float2 { arg1 = simd_int2(Int32(arg.x), Int32(arg.y)) }
        let this = try TextContent(text: arg0, size: arg1)
        return as_value(env, this)
    }
    catch {
        napi_throw_error(env, nil, "make_text \(error)")
        return nil
    }
}

// MARK: backgroundColor

func get_text_backgroundColor(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? TextContent else { return nil }
    return as_value(env!, this.backgroundColor)
}

func set_text_backgroundColor(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? TextContent else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = as_simd(args[0]) as? simd_float4 { this.backgroundColor = arg0 }
    if let arg0 = as_simd(args[0]) as? Float { this.backgroundColor = simd_float4(repeating: arg0) }
    return nil
}

// MARK: foregroundColor

func get_text_foregroundColor(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? TextContent else { return nil }
    return as_value(env!, this.foregroundColor)
}

func set_text_foregroundColor(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? TextContent else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = as_simd(args[0]) as? simd_float4 { this.foregroundColor = arg0 }
    if let arg0 = as_simd(args[0]) as? Float { this.foregroundColor = simd_float4(repeating: arg0) }
    return nil
}

// MARK: text

func get_text_text(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? TextContent else { return nil }
    return as_value(env!, this.text)
}

func set_text_text(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? TextContent else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? String { this.text = arg0 }
    return nil
}

// MARK: textSize

func get_text_textSize(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? TextContent else { return nil }
    return as_value(env!, this.textSize)
}

func set_text_textSize(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? TextContent else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? Float { this.textSize = arg0 }
    return nil
}

