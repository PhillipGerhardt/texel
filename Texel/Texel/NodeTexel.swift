//
//  NodeTexel.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import AppKit.NSApplication
import Dispatch
import UniformTypeIdentifiers
import AVFoundation

let texel_descriptors: [napi_property_descriptor] = [
    napi_property_descriptor(utf8name: strdup("layers"), name: nil, method: nil, getter: get_layers, setter: set_layers, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("clearColor"), name: nil, method: nil, getter: get_clearColor, setter: set_clearColor, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("size"), name: nil, method: nil, getter: get_size, setter: nil, value: nil, attributes: napi_default_jsproperty, data: nil),
    napi_property_descriptor(utf8name: strdup("quit"), name: nil, method: quit, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("makeThumbnail"), name: nil, method: make_thumbnail, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("enums"), name: nil, method: enums, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("shuffle"), name: nil, method: shuffle, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("contentsOfDirectory"), name: nil, method: contents_of_directory, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("isMovie"), name: nil, method: is_movie, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("isImage"), name: nil, method: is_image, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("canReadAsset"), name: nil, method: can_read_asset, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("filterNames"), name: nil, method: filter_names, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("layerAt"), name: nil, method: layer_at, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("isSame"), name: nil, method: is_same, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),

    napi_property_descriptor(utf8name: strdup("Animation"), name: nil, method: make_animation, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Layer"), name: nil, method: make_layer, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Image"), name: nil, method: make_image, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Movie"), name: nil, method: make_movie, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Text"), name: nil, method: make_text, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Fragment"), name: nil, method: make_fragment, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Ticker"), name: nil, method: make_ticker, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("VisionDetector"), name: nil, method: make_vision_detector, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Wave"), name: nil, method: make_wave, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("GameOfLife"), name: nil, method: make_game_of_life, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Raw"), name: nil, method: make_raw, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),
    napi_property_descriptor(utf8name: strdup("Filter"), name: nil, method: make_filter, getter: nil, setter: nil, value: nil, attributes: napi_default_method, data: nil),

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

// MARK: - thumbnail

func make_thumbnail(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count >= 2 else { return nil }
    guard let arg0 = args[0] as? String else { return nil }
    guard let arg1 = args[1] as? String else { return nil }
    var arg2 = simd_float2(640, 480)
    if args.count > 2, let arg = as_simd(args[2]) as? simd_float2 { arg2 = arg}
    Engine.saveThumbnail(of: arg0, to: arg1, size: arg2)
    return nil
}

// MARK: - enums

func enums(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    var result = [String:[String]]()
    result[String(describing: Ease.self)] = Ease.allCases.map{$0.rawValue}
    result[String(describing: ScaleMode.self)] = ScaleMode.allCases.map{$0.rawValue}
    result[String(describing: VerticalAlignment.self)] = VerticalAlignment.allCases.map{$0.rawValue}
    result[String(describing: HorizontalAlignment.self)] = HorizontalAlignment.allCases.map{$0.rawValue}
    return as_value(env, result)
}

// MARK: - shuffle

func shuffle(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard var arg0 = args[0] as? [Any] else { return nil }
    arg0.shuffle()
    return as_value(env, arg0)
}

// - MARK - contents_of_directory

func contents_of_directory(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count >= 1 else { return nil }
    guard let arg0 = args[0] as? String else { return nil }
    var arg1 = false
    if args.count > 1, let arg = args[1] as? Bool { arg1 = arg }

    var urls = [URL]()
    let url = URL(fileURLWithPath: arg0)
    var options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants]
    if !arg1 { options.insert(.skipsSubdirectoryDescendants) }

    if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: options) {
        for case let fileURL as URL in enumerator {
            do {
                let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                if fileAttributes.isRegularFile! {
                    urls.append(fileURL)
                }
            } catch { print(error, fileURL) }
        }
    }

    let result = urls.map { $0.path }
    return as_value(env, result)
}

// MARK: - is_movie

func is_movie(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let arg0 = args[0] as? String else { return nil }
    let url = URL(fileURLWithPath: arg0)
    guard let type = UTType(filenameExtension: url.pathExtension) else { return nil }
    let result = type.conforms(to: .audiovisualContent)
    return as_value(env, result)
}

// MARK: - is_image

func is_image(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let arg0 = args[0] as? String else { return nil }
    let url = URL(fileURLWithPath: arg0)
    guard let type = UTType(filenameExtension: url.pathExtension) else { return nil }
    let result = type.conforms(to: .image) && !type.conforms(to: .pdf)
    return as_value(env, result)
}

// MARK: - can_read_asset

func can_read_asset(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let arg0 = args[0] as? String else { return nil }

    var result = true
    let url = URL(fileURLWithPath: arg0)
    let asset = AVAsset(url: url)
    do {
        _ = try AVAssetReader(asset: asset)
    }
    catch {
        result = false
    }
    return as_value(env, result)
}

// MARK: - filterNames

func filter_names(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    let result = CIFilter.filterNames(inCategory: nil)
    return as_value(env, result)
}

// MARK: - layerAt

func layer_at(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 1 else { return nil }
    guard let arg0 = as_simd(args[0]) as? simd_float2 else { return nil }
    if let layer = engine.scene.layer(at: arg0) {
        return as_value(env, layer)
    }
    return nil
}

// MARK: - isSame

func is_same(_ env: napi_env?, _ info: napi_callback_info?) -> napi_value? {
    guard let args = get_args(env, info), args.count == 2 else { return nil }
    guard let arg0 = args[0] as? AnyObject else { return nil }
    guard let arg1 = args[1] as? AnyObject else { return nil }
    let res = arg0 === arg1
    return as_value(env, res)
}
