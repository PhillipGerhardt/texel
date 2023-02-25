//
//  NodeCall.swift
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

import AppKit

var node_fun_ref: napi_threadsafe_function?
var node_function: napi_threadsafe_function_call_js? = { env, tsfn_cb, context, data in

    guard let data = data else { return }
    let event = Unmanaged<NSEvent>.fromOpaque(data).takeRetainedValue()
    guard event.type == .keyDown else { return }

    var script = ""

    if event.type == .keyDown {
        script = """
        try {
            texel.onKeyDown(\(event.keyCode));
        } catch (error) {
            console.log(error);
        }
        """
    }

    let s = as_value(env, script)
    var res: napi_value?
    guard napi_run_script(env, s, &res) == napi_ok else {
        print("napi_run_script failed")
        return
    }

//    if let res {
//        let result = as_any(env, res)
//        print("result", String(describing: result))
//    }
}

func node_create_calls(_ env: napi_env) {
    let resource_name = as_value(env, "RESOURCE_NAME")
    guard napi_create_threadsafe_function(env, nil, nil, resource_name, 0, 1, nil, nil, nil, node_function, &node_fun_ref) == napi_ok else {
        print("napi_create_threadsafe_function failed")
        return
    }
}

func NodeInterpretEvent(_ event: NSEvent) {
    if let node_fun_ref = node_fun_ref {
        let data = Unmanaged.passRetained(event).toOpaque()
        napi_call_threadsafe_function(node_fun_ref, data, napi_tsfn_nonblocking)
    }
}

func node_create_addon(_ env: napi_env, _ exports: napi_value) -> napi_value {
    print(#function)
    node_create_calls(env)
    napi_define_properties(env, exports, texel_descriptors.count, texel_descriptors)
    return exports
}

func NodeStart() {
    print(#function)
    mynode_create_addon = node_create_addon
    guard let scriptsURL = Bundle.main.url(forResource: "scripts", withExtension: nil) else { return }
    FileManager.default.changeCurrentDirectoryPath(scriptsURL.path)
    let args = ["node", "--expose-gc", "--trace-deprecation", "index.js"]
    var argv = args.map{strdup($0)!}
    let node_modules_path = scriptsURL.path.appending("/node_modules")
    MyNode_start(node_modules_path, Int32(argv.count), &argv)
}
