//
//  Node.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

/**
 * If JS garbage collector finalizes our wrapped objects we need to decrease the retain count
 * of the wrapped object. ARC will do that for us after we called takeRetainedValue().
 */
func object_finalizer(_ env: napi_env?, _ finalize_data: UnsafeMutableRawPointer?, _ finalize_hint: UnsafeMutableRawPointer?) {
    let _ = Unmanaged<AnyObject>.fromOpaque(finalize_data!).takeRetainedValue()
}

/**
 * Wrap a Swift type into a JS object.
 * The concrete type is stored as a tag in the JS object. The tag is used later to check if we are unwrapping the correct type.
 */
func wrap<T: AnyObject>(_ env: napi_env?, _ t: T) -> napi_value?
{
    var result: napi_value?
    guard napi_create_object(env!, &result) == napi_ok else {
        napi_throw_error(env, nil, "napi_create_object")
        return nil
    }
    var tag: napi_type_tag = napi_type_tag(lower: UInt64(bitPattern: Int64(ObjectIdentifier(T.self).hashValue)),
                                           upper: UInt64(bitPattern: Int64(ObjectIdentifier(T.self).hashValue)))
    guard napi_type_tag_object(env, result, &tag) == napi_ok else {
        napi_throw_error(env, nil, "napi_type_tag_object")
        return nil
    }
    guard napi_wrap(env, result, Unmanaged.passRetained(t).toOpaque(), object_finalizer, nil, nil) == napi_ok else {
        napi_throw_error(env, nil, "napi_wrap")
        return nil
    }
    return result
}

/**
 * Unrap a Swift type from a JS object.
 */
func unwrap_this(_ env: napi_env?, _ info: napi_callback_info?) -> AnyObject? {
    var this: napi_value?
    guard napi_get_cb_info(env!, info!, nil, nil, &this, nil) == napi_ok else {
        napi_throw_error(env, nil, "napi_get_cb_info")
        return nil
    }
    var ptr: UnsafeMutableRawPointer?
    guard napi_unwrap(env, this, &ptr) == napi_ok else {
        napi_throw_error(env, nil, "napi_unwrap")
        return nil
    }
    let t = Unmanaged<AnyObject>.fromOpaque(ptr!).takeUnretainedValue()
    return t
}

/**
 * Try to cast a JS to a Swift type.
 * Will work only for types that has been wrapped before.
 * If the type tag does not match the cast fails.
 */
func cast_to<T: AnyObject>(_ env: napi_env?, _ value: napi_value?) -> T?
{
    var typeTag: napi_type_tag = napi_type_tag(lower: UInt64(bitPattern: Int64(ObjectIdentifier(T.self).hashValue)),
                                               upper: UInt64(bitPattern: Int64(ObjectIdentifier(T.self).hashValue)))
    var is_type: Bool = true
    guard napi_check_object_type_tag(env, value, &typeTag, &is_type) == napi_ok else {
        napi_throw_error(env, nil, "napi_check_object_type_tag")
        return nil
    }
//    print("is_type", is_type)
    guard is_type else {
//        napi_throw_type_error (env, nil, "!is_type \(T.self)")
        return nil
    }
    var ptr: UnsafeMutableRawPointer?
    guard napi_unwrap(env, value, &ptr) == napi_ok else {
        napi_throw_error(env, nil, "napi_unwrap")
        return nil
    }
    let t = Unmanaged<T>.fromOpaque(ptr!).takeUnretainedValue()
    return t
}

/**
 * Try to cast a Swift array to a simd type.
 */
func as_simd(_ x: Any) -> Any? {
    if let x = x as? Float { return x }
    if let x = x as? [Float], x.count == 2 { return simd_float2(x[0], x[1]) }
    if let x = x as? [Float], x.count == 3 { return simd_float3(x[0], x[1], x[2]) }
    if let x = x as? [Float], x.count == 4 { return simd_float4(x[0], x[1], x[2], x[3]) }
    if let x = x as? [Any], x.count == 2 {
        if let p = as_simd(x[0]) as? Float,
           let q = as_simd(x[1]) as? simd_float3 {
            return simd_quatf(angle: p, axis: q)
        }
    }
    return nil
}

/**
 * Convert a JS value to Swift.
 */
func as_any(_ env: napi_env?, _ val: napi_value) -> Any? {

    var string_size: size_t = 0
    if napi_get_value_string_utf8(env!, val, nil, 0, &string_size) == napi_ok {
        var a : [Int8] = [Int8](repeating: 0, count: string_size + 1)
        if napi_get_value_string_utf8(env!, val, &a, string_size + 1, &string_size) == napi_ok {
            return String(cString: a)
        }
    }

    var double_value: Double = 0
    if napi_get_value_double(env!, val, &double_value) == napi_ok {
        return Float(double_value)
    }

    var bool_value: Bool = false
    if napi_get_value_bool(env!, val, &bool_value) == napi_ok {
        return bool_value
    }

    var is_array = false
    if napi_is_array(env!, val, &is_array) == napi_ok, is_array {
        var array_length: uint32 = 0
        if napi_get_array_length(env, val, &array_length) == napi_ok {
            var result = [Any]()
            for i in (0..<array_length) {
                var elem: napi_value?
                guard napi_get_element(env!, val, i, &elem) == napi_ok else {
                    napi_throw_error(env, nil, "napi_get_element")
                    return nil
                }
                guard let a = as_any(env!, elem!) else { return nil }
                result.append(a)
            }
            return result
        }
    }

    if let t: Layer = cast_to(env!, val) { return t }
    if let t: Animation = cast_to(env!, val) { return t }
    if let t: ImageContent = cast_to(env!, val) { return t }
    if let t: MovieContent = cast_to(env!, val) { return t }
    if let t: TextContent = cast_to(env!, val) { return t }
    if let t: FragmentContent = cast_to(env!, val) { return t }
    if let t: TickerContent = cast_to(env!, val) { return t }
    if let t: VisionDetectorContent = cast_to(env!, val) { return t }
    if let t: WaveContent = cast_to(env!, val) { return t }
    if let t: GameOfLifeContent = cast_to(env!, val) { return t }
    if let t: RawContent = cast_to(env!, val) { return t }
    if let t: FilterContent = cast_to(env!, val) { return t }
    if let t: MapContent = cast_to(env!, val) { return t }
    if let t: FFContent = cast_to(env!, val) { return t }

    return nil
}

/**
 * Convert a Swift type to a JS value.
 */
func as_value(_ env: napi_env?, _ t: Any) -> napi_value? {

    /* Convert classes */

    if let t = t as? Layer, let val = wrap(env!, t) {
        napi_define_properties(env, val, layer_descriptors.count, layer_descriptors)
        return val
    }
    if let t = t as? ImageContent,  let val = wrap(env!, t) {
        napi_define_properties(env, val, content_descriptors.count, content_descriptors)
        return val
    }
    if let t = t as? MovieContent,  let val = wrap(env!, t) {
        napi_define_properties(env, val, content_descriptors.count, content_descriptors)
        return val
    }
    if let t = t as? TextContent,  let val = wrap(env!, t) {
        napi_define_properties(env, val, text_descriptors.count, text_descriptors)
        return val
    }
    if let t = t as? FragmentContent,  let val = wrap(env!, t) {
        napi_define_properties(env, val, fragment_descriptors.count, fragment_descriptors)
        return val
    }
    if let t = t as? TickerContent, let val = wrap(env!, t) {
        napi_define_properties(env, val, ticker_descriptors.count, ticker_descriptors)
        return val
    }
    if let t = t as? VisionDetectorContent, let val = wrap(env!, t) {
        napi_define_properties(env, val, content_descriptors.count, content_descriptors)
        return val
    }
    if let t = t as? WaveContent, let val = wrap(env!, t) {
        napi_define_properties(env, val, content_descriptors.count, content_descriptors)
        return val
    }
    if let t = t as? GameOfLifeContent, let val = wrap(env!, t) {
        napi_define_properties(env, val, content_descriptors.count, content_descriptors)
        return val
    }
    if let t = t as? RawContent, let val = wrap(env!, t) {
        napi_define_properties(env, val, content_descriptors.count, content_descriptors)
        return val
    }
    if let t = t as? FilterContent, let val = wrap(env!, t) {
        napi_define_properties(env, val, filter_descriptors.count, filter_descriptors)
        return val
    }
    if let t = t as? MapContent, let val = wrap(env!, t) {
        napi_define_properties(env, val, content_descriptors.count, content_descriptors)
        return val
    }
    if let t = t as? FFContent, let val = wrap(env!, t) {
        napi_define_properties(env, val, content_descriptors.count, content_descriptors)
        return val
    }
    if let t = t as? Animation, let val = wrap(env!, t) {
        napi_define_properties(env, val, animation_descriptors.count, animation_descriptors)
        return val
    }

    /* Convert basic types */

    if let t = t as? Bool {
        var val: napi_value?
        guard napi_get_boolean(env, t, &val) == napi_ok else {
            napi_throw_error(env, nil, "napi_get_boolean")
            return nil
        }
        return val;
    }
    if let t = t as? Int {
        var val: napi_value?
        guard napi_create_int64(env, Int64(t), &val) == napi_ok else {
            napi_throw_error(env, nil, "napi_create_int64")
            return nil
        }
        return val
    }
    if let t = t as? Int32 {
        var val: napi_value?
        guard napi_create_int32(env, t, &val) == napi_ok else {
            napi_throw_error(env, nil, "napi_create_int32")
            return nil
        }
        return val
    }
    if let t = t as? Int64 {
        var val: napi_value?
        guard napi_create_int64(env, t, &val) == napi_ok else {
            napi_throw_error(env, nil, "napi_create_int64")
            return nil
        }
        return val
    }
    if let t = t as? Float {
        var val: napi_value?
        guard napi_create_double(env, Double(t), &val) == napi_ok else {
            napi_throw_error(env, nil, "napi_create_double")
            return nil
        }
        return val
    }
    if let t = t as? String {
        var val: napi_value?
        guard napi_create_string_utf8(env, t, t.count, &val) == napi_ok else {
            napi_throw_error(env, nil, "napi_create_string_utf8")
            return nil
        }
        return val
    }

    /* Convert simd types to arrays */

    if let t = t as? simd_int2 { return as_value(env, [t.x, t.y]) }
    if let t = t as? simd_float2 { return as_value(env, [t.x, t.y]) }
    if let t = t as? simd_float3 { return as_value(env, [t.x, t.y, t.z]) }
    if let t = t as? simd_float4 { return as_value(env, [t.x, t.y, t.z, t.w]) }
    if let t = t as? simd_quatf { return as_value(env, [t.angle, [t.axis.x, t.axis.y, t.axis.z]]) }

    /* Convert dictionary to JS object */

    if let t = t as? [String:Any] {
        var result: napi_value?
        guard napi_create_object(env!, &result) == napi_ok else {
            napi_throw_error(env, nil, "napi_create_object")
            return nil
        }
        for (key, value) in t {
            guard let v = as_value(env, value) else { return nil }
            guard napi_set_named_property(env, result, key, v) == napi_ok else {
                napi_throw_error(env, nil, "napi_set_named_property")
                return nil
            }
        }
        return result
    }

    /* Convert arrays like the scene's layers */

    if let t = t as? [Any] {
        var result: napi_value?
        guard napi_create_array_with_length(env!, t.count, &result) == napi_ok else {
            napi_throw_error(env, nil, "napi_create_array_with_length")
            return nil
        }
        for (i, t) in t.enumerated() {
            guard let v = as_value(env, t) else { return nil }
            guard napi_set_element(env, result, UInt32(i), v) == napi_ok else {
                napi_throw_error(env, nil, "napi_set_element")
                return nil
            }
        }
        return result
    }

    print("as_value: unsupported \(t)")
    return nil
}

/**
 * Convert the callback parameters in napi_callback_info to Swift array.
 */
func get_args(_ env: napi_env?, _ info: napi_callback_info?) -> [Any]? {
    var argc: Int = 0
    guard napi_get_cb_info(env!, info!, &argc, nil, nil, nil) == napi_ok else {
        napi_throw_error(env, nil, "napi_get_cb_info")
        return nil
    }
    var argv: [napi_value?] = [napi_value?](repeating: nil, count: argc)
    guard napi_get_cb_info(env!, info!, &argc, &argv, nil, nil) == napi_ok else {
        napi_throw_error(env, nil, "napi_get_cb_info")
        return nil
    }
    var result = [Any]()
    for val in argv {
        guard let a = as_any(env!, val!) else {
            return nil
        }
        result.append(a)
    }
    return result
}

