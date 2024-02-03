//
//  NodeContent.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import Foundation

let content_descriptors: [napi_property_descriptor] = [
    napi_property_descriptor(utf8name: strdup("start"), name: nil, method: content_start, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("stop"), name: nil, method: content_stop, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("seek"), name: nil, method: content_seek, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("volume"), name: nil, method: nil, getter: get_content_volume, setter: set_content_volume, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("size"), name: nil, method: nil, getter: get_content_size, setter: nil, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("position"), name: nil, method: nil, getter: get_content_position, setter: set_content_position, value: nil, attributes: napi_default_jsproperty, data: nil),
];

// MARK: - start

func content_start(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? Content else { return nil }
    this.start()
    return nil
}

// MARK: - stop

func content_stop(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? Content else { return nil }
    this.stop()
    return nil
}

// MARK: - seek

func content_seek(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? Content else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? Float { this.seek(to: arg0) }
    return nil
}

// MARK: - volume

func get_content_volume(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Content else { return nil }
    return as_value(env, this.volume)
}

func set_content_volume(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Content else { return nil }
    if let arg0 = args[0] as? Float { this.volume = arg0 }
    return nil
}

// MARK: - size

func get_content_size(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Content else { return nil }
    return as_value(env, this.size)
}

// MARK: - position

func get_content_position(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Content else { return nil }
    return as_value(env, this.position)
}

func set_content_position(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Content else { return nil }
    if let arg0 = args[0] as? Float { this.position = arg0 }
    return nil
}
