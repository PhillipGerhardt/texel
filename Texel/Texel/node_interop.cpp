//
//  node_interop.cpp
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

#include "node_interop.h"

#include <stdlib.h> // setenv
#include <node_api.h>
#define NODE_WANT_INTERNALS 1

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#include <node_binding.h>
#pragma clang diagnostic pop

#include "node_snapshot_builder.h"

namespace node {
const SnapshotData* SnapshotBuilder::GetEmbeddedSnapshotData() {
    return nullptr;
}
}  // namespace node

#ifdef __cplusplus
extern "C" {
#endif

void MyNode_register(void) {
    static napi_module _module =
    {
        NAPI_MODULE_VERSION,
        NM_F_LINKED,
        __FILE__,
        mynode_create_addon,
        "texel",
        nullptr,
        {0},
    };
    napi_module_register(&_module);
}

void MyNode_start(const char* __nullable node_path, int argc, char* __nonnull* __nonnull argv) {
    MyNode_register();
    if (node_path) {
        setenv("NODE_PATH", node_path, 1);
    }
    node::Start(argc, argv);
}

void MyNode_stop() {
// TODO: How to get the env?
//    Environment* env = ...;
//    Node::Stop(env);
}

napi_value __nonnull (* __nonnull mynode_create_addon)(napi_env __nonnull env, napi_value __nonnull exports) = nullptr;

#ifdef __cplusplus
}
#endif
