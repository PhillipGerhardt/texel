//
//  NodeTexel.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import AppKit.NSApplication
import Dispatch

let texel_descriptors: [napi_property_descriptor] = [
    napi_property_descriptor(utf8name: strdup("layers"), name: nil, method: nil, getter: get_layers, setter: set_layers, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("clearColor"), name: nil, method: nil, getter: get_clearColor, setter: set_clearColor, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("size"), name: nil, method: nil, getter: get_size, setter: nil, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("quit"), name: nil, method: quit, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Animation"), name: nil, method: make_animation, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Layer"), name: nil, method: make_layer, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Image"), name: nil, method: make_image, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Movie"), name: nil, method: make_movie, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
]

// MARK: - layers

func get_layers(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let layers = engine.scene.layers
    return as_value(env, layers)
}

func set_layers(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let arg0 = args[0] as? [Layer] else { return nil }
    engine.scene.layers = arg0
    return nil
}

// MARK: - clearColor

func get_clearColor(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    return as_value(env, engine.clearColor)
}

func set_clearColor(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let arg0 = as_simd(args[0]) as? simd_float4 else { return nil }
    engine.clearColor = arg0
    return nil
}


// MARK: - size

func get_size(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    return as_value(env, engine.scene.size)
}

func quit(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    DispatchQueue.main.async {
        NSApplication.shared.terminate(nil)
    }
    return nil
}
