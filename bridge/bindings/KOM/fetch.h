/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_FETCH_H
#define KRAKEN_FETCH_H

#include "jsa.h"
#include <memory>

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

void bindFetch(std::unique_ptr<JSContext> &context);
void unbindFetch();
void invokeFetchCallback(std::unique_ptr<JSContext> &context, int callbackId,
                         const std::string &error, int statusCode,
                         const std::string &body);
} // namespace binding
} // namespace kraken

#endif /* KRAKEN_FETCH_H */
