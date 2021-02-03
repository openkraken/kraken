/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "all_collection.h"
#include "bindings/jsc/js_context_internal.h"
#include "element.h"
#include "node.h"

#include "bindings/jsc/DOM/elements/anchor_element.h"
#include "bindings/jsc/DOM/elements/animation_player_element.h"
#include "bindings/jsc/DOM/elements/audio_element.h"
#include "bindings/jsc/DOM/elements/canvas_element.h"
#include "bindings/jsc/DOM/elements/iframe_element.h"
#include "bindings/jsc/DOM/elements/image_element.h"
#include "bindings/jsc/DOM/elements/input_element.h"
#include "bindings/jsc/DOM/elements/object_element.h"
#include "bindings/jsc/DOM/elements/video_element.h"

namespace kraken::binding::jsc {

void bindDocument(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_DOCUMENT_H
