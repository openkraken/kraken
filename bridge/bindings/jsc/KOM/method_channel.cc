/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "method_channel.h"

namespace kraken::binding::jsc {

JSMethodChannel::JSMethodChannel(JSContext *context) : HostObject(context, "methodChannel") {

}

};
