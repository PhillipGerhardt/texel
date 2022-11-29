//
//  NodeLayer.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import Foundation

let layer_descriptors: [napi_property_descriptor] = [
    napi_property_descriptor(utf8name: strdup("size"), name: nil, method: nil, getter: get_layer_size, setter: set_layer_size, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("position"), name: nil, method: nil, getter: get_layer_position, setter: set_layer_position, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("clip"), name: nil, method: nil, getter: get_layer_clip, setter: set_layer_clip, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("draw"), name: nil, method: nil, getter: get_layer_draw, setter: set_layer_draw, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("content"), name: nil, method: nil, getter: get_layer_content, setter: set_layer_content, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("contentScaling"), name: nil, method: nil, getter: get_layer_contentScaling, setter: set_layer_contentScaling, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("contentHorizontalAlignment"), name: nil, method: nil, getter: get_layer_contentHorizontalAlignment, setter: set_layer_contentHorizontalAlignment, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("contentVerticalAlignment"), name: nil, method: nil, getter: get_layer_contentVerticalAlignment, setter: set_layer_contentVerticalAlignment, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("orientation"), name: nil, method: nil, getter: get_layer_orientation, setter: set_layer_orientation, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("rotation"), name: nil, method: nil, getter: get_layer_rotation, setter: set_layer_rotation, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("color"), name: nil, method: nil, getter: get_layer_color, setter: set_layer_color, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("contentColor"), name: nil, method: nil, getter: get_layer_contentColor, setter: set_layer_contentColor, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("sublayers"), name: nil, method: nil, getter: get_layer_sublayers, setter: set_layer_sublayers, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("pivot"), name: nil, method: nil, getter: get_layer_pivot, setter: set_layer_pivot, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("contentVolume"), name: nil, method: nil, getter: get_layer_contentVolume, setter: set_layer_contentVolume, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("contentSize"), name: nil, method: nil, getter: get_layer_contentSize, setter: nil, value: nil, attributes: napi_default_jsproperty, data: nil),
];

func make_layer(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    guard let args = get_args(env!, info!) else { return nil }
    guard args.count == 0 else { return nil }
    let this = Layer();
    return as_value(env, this)
}

// MARK: - size

func get_layer_size(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let layer = unwrap_this(env, info) as? Layer else { return nil }
    return as_value(env, layer.size)
}

func set_layer_size(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? Animation { arg0.start(src: this.size, target: &this.$size) }
    if let arg0 = as_simd(args[0]) as? simd_float2 { this.size = arg0 }
    return nil
}

// MARK: - position

func get_layer_position(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? Layer else { return nil }
    return as_value(env!, this.position)
}

func set_layer_position(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? Animation { arg0.start(src: this.position, target: &this.$position) }
    if let arg0 = as_simd(args[0]) as? simd_float2 { this.position = arg0 }
    return nil
}

// MARK: - clip

func get_layer_clip(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? Layer else { return nil }
    return as_value(env!, this.clip)
}

func set_layer_clip(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? Bool { this.clip = arg0 }
    return nil
}

// MARK: - draw

func get_layer_draw(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? Layer else { return nil }
    return as_value(env!, this.draw)
}

func set_layer_draw(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    if let arg0 = args[0] as? Bool { this.draw = arg0 }
    return nil
}

// MARK: - content

func get_layer_content(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    return as_value(env, this.content as Any)
}

func set_layer_content(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let content: Content = args[0] as? Content else { return nil }
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    print("setting content", content)
    this.content = content
    return nil
}

// MARK: - contentScaling

func get_layer_contentScaling(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    return as_value(env, this.contentScaling.rawValue)
}

func set_layer_contentScaling(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    guard let val = args[0] as? String else { return nil }
    guard let val = ScaleMode(rawValue: val) else { return nil }
    this.contentScaling = val
    return nil
}

// MARK: - contentHorizontalAlignment

func get_layer_contentHorizontalAlignment(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    return as_value(env, this.contentHorizontalAlignment.rawValue)
}

func set_layer_contentHorizontalAlignment(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    guard let val = args[0] as? String else { return nil }
    guard let val = HorizontalAlignment(rawValue: val) else { return nil }
    this.contentHorizontalAlignment = val
    return nil
}

// MARK: - contentVerticalAlignment

func get_layer_contentVerticalAlignment(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    return as_value(env, this.contentVerticalAlignment.rawValue)
}

func set_layer_contentVerticalAlignment(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    guard let val = args[0] as? String else { return nil }
    guard let val = VerticalAlignment(rawValue: val) else { return nil }
    this.contentVerticalAlignment = val
    return nil
}

// MARK: - orientation

func get_layer_orientation(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    return as_value(env, this.orientation)
}

func set_layer_orientation(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    if let arg0 = as_simd(args[0]) as? simd_quatf { this.orientation = arg0 }
    return nil
}

// MARK: - rotation

func get_layer_rotation(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    return as_value(env, this.rotation)
}

func set_layer_rotation(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    if let arg0 = args[0] as? Animation { arg0.start(src: this.rotation, target: &this.$rotation) }
    if let arg0 = args[0] as? Float { this.rotation = arg0 }
    return nil
}

// MARK: - color

func get_layer_color(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    return as_value(env, this.color)
}

func set_layer_color(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    if let arg0 = args[0] as? Animation { arg0.start(src: this.color, target: &this.$color) }
    if let arg0 = as_simd(args[0]) as? simd_float4 { this.color = arg0 }
    if let arg0 = as_simd(args[0]) as? Float { this.color = simd_float4(repeating: arg0) }
    return nil
}

// MARK: - contentColor

func get_layer_contentColor(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    return as_value(env, this.contentColor)
}

func set_layer_contentColor(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    if let arg0 = args[0] as? Animation { arg0.start(src: this.contentColor, target: &this.$contentColor) }
    if let arg0 = as_simd(args[0]) as? simd_float4 { this.contentColor = arg0 }
    if let arg0 = as_simd(args[0]) as? Float { this.contentColor = simd_float4(repeating: arg0) }
    return nil
}

// MARK: - sublayers

func get_layer_sublayers(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    let layers = this.sublayers
    return as_value(env, layers)
}

func set_layer_sublayers(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    guard let arg0 = args[0] as? [Layer] else { return nil }
    this.sublayers = arg0
    return nil
}

// MARK: - pivot

func get_layer_pivot(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    return as_value(env, this.pivot)
}

func set_layer_pivot(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    if let arg0 = args[0] as? Animation { arg0.start(src: this.pivot, target: &this.$pivot) }
    if let arg0 = as_simd(args[0]) as? simd_float2 { this.pivot = arg0 }
    return nil
}

// MARK: - contentVolume

func get_layer_contentVolume(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    return as_value(env, this.contentVolume)
}

func set_layer_contentVolume(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? Layer else { return nil }
    if let arg0 = args[0] as? Animation { arg0.start(src: this.contentVolume, target: &this.$contentVolume) }
    if let arg0 = as_simd(args[0]) as? Float { this.contentVolume = arg0 }
    return nil
}

// MARK: - contentSize

func get_layer_contentSize(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let layer = unwrap_this(env, info) as? Layer else { return nil }
    return as_value(env, layer.contentSize)
}

