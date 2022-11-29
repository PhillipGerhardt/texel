//
//  node_interop.hpp
//  Texel
//
//  Created by Phillip Gerhardt on 27.11.22.
//

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <node_api.h>

/**
 * Start the node runloop.
 */
extern void MyNode_start(const char* __nullable node_path, int argc, char* __nonnull* __nonnull argv);
/**
 * Stop the node runloop.
 * FIXME: Currently does nothing.
 */
extern void MyNode_stop();

extern napi_value __nonnull (* __nonnull mynode_create_addon)(napi_env __nonnull env, napi_value __nonnull exports);

#ifdef __cplusplus
}
#endif
