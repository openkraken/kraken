/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#include "jsa.h"
#include <memory>

namespace kraken::binding::jsa {
using namespace alibaba::jsa;

void bindKraken(std::unique_ptr<JSContext> &context);
} // namespace kraken
