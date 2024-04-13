//
//  NodeFilter.swift
//  Texel
//
//  Created by Phillip Gerhardt on 25.02.23.
//

let filter_descriptors: [napi_property_descriptor] = [
    napi_property_descriptor(utf8name: strdup("set"), name: nil, method: filter_set, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("time"), name: nil, method: nil, getter: get_filter_time, setter: set_filter_time, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("attributes"), name: nil, method: nil, getter: get_filter_attributes, setter: nil, value: nil, attributes: napi_default_jsproperty, data: nil),
] + content_descriptors

func make_filter(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value?
{
    do {
        guard let args = get_args(env!, info!) else { return nil }
        guard args.count == 2 else { return nil }
        guard let arg0 = args[0] as? String else { return nil }
        guard let arg1 = as_simd(args[1]) as? simd_float2 else { return nil }
        let this = try FilterContent(name: arg0, size: simd_int2(Int32(arg1.x), Int32(arg1.y)))
        return as_value(env, this)
    }
    catch {
        napi_throw_error(env, nil, "make_filter \(error)")
        return nil
    }
}

// MARK: - set

func filter_set(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env, info) as? FilterContent else { return nil }
    guard let args = get_args(env!, info!) else { return nil }
    guard args.count == 2 else { return nil }
    guard let arg0 = args[0] as? String else { return nil }
    let arg1 = args[1]
    this.set(arg0, arg1)
    return nil
}

// MARK: - time

func get_filter_time(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? FilterContent else { return nil }
    return as_value(env, this.time)
}

func set_filter_time(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info) else { return nil }
    guard args.count == 1 else { return nil }
    guard let this = unwrap_this(env!, info!) as? FilterContent else { return nil }
    Animations.shared.stop(this, keyPath: \FilterContent.$time)
    if let arg0 = args[0] as? Animation { arg0.start(src: this.time, target: this, keyPath: \FilterContent.$time) }
    if let arg0 = args[0] as? Float { this.time = arg0 }
    return nil
}

// MARK: - attributes

func get_filter_attributes(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let this = unwrap_this(env!, info!) as? FilterContent else { return nil }
    return as_value(env, this.attributes)
}
