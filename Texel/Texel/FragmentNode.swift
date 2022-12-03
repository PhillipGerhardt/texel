//
//  FragmentNode.swift
//  Texel
//
//  Created by Phillip Gerhardt on 03.12.22.
//

let fragment_descriptors: [napi_property_descriptor] = [
    napi_property_descriptor(utf8name: strdup("source"), name: nil, method: nil, getter: get_fragment_source, setter: set_fragment_source, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("textureOne"), name: nil, method: nil, getter: get_fragment_texture_one, setter: set_fragment_texture_one, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("textureTwo"), name: nil, method: nil, getter: get_fragment_texture_two, setter: set_fragment_texture_two, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("textureThree"), name: nil, method: nil, getter: get_fragment_texture_three, setter: set_fragment_texture_three, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("textureFour"), name: nil, method: nil, getter: get_fragment_texture_four, setter: set_fragment_texture_four, value: nil, attributes: napi_default_method, data: nil),
] + content_descriptors

func make_fragment(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    let this = FragmentContent()
    return as_value(env, this)
}

// MARK: source

func get_fragment_source(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? FragmentContent else { return nil }
    return as_value(env!, this.source)
}

func set_fragment_source(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? FragmentContent else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? String { this.source = arg0 }
    return nil
}

// MARK: textureOne

func set_fragment_texture_one(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? FragmentContent else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? TextureContent { this.textureOne = arg0 }
    return nil
}

func get_fragment_texture_one(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? FragmentContent else { return nil }
    return as_value(env, this.textureOne as Any)
}

// MARK: textureTwo

func set_fragment_texture_two(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? FragmentContent else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? TextureContent { this.textureTwo = arg0 }
    return nil
}

func get_fragment_texture_two(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? FragmentContent else { return nil }
    return as_value(env, this.textureTwo as Any)
}

// MARK: textureThree

func set_fragment_texture_three(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? FragmentContent else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? TextureContent { this.textureThree = arg0 }
    return nil
}

func get_fragment_texture_three(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? FragmentContent else { return nil }
    return as_value(env, this.textureThree as Any)
}

// MARK: textureFour

func set_fragment_texture_four(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? FragmentContent else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? TextureContent { this.textureFour = arg0 }
    return nil
}

func get_fragment_texture_four(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? FragmentContent else { return nil }
    return as_value(env, this.textureFour as Any)
}
