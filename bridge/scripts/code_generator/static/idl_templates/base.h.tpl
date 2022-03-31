/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_<%= blob.filename.toUpperCase() %>_H
#define KRAKENBRIDGE_<%= blob.filename.toUpperCase() %>_H

#include <quickjs/quickjs.h>
#include "bindings/qjs/wrapper_type_info.h"
#include "bindings/qjs/qjs_interface_bridge.h"
#include "bindings/qjs/dictionary_base.h"

<%= content %>

#endif //KRAKENBRIDGE_<%= blob.filename.toUpperCase() %>T_H
