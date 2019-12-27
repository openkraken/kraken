/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/


#ifndef KRAKEN_FETCH_H
#define KRAKEN_FETCH_H

#include "jsa.h"

namespace kraken {
namespace binding {

void bindFetch(alibaba::jsa::JSContext *context);
void invokeFetchCallback(
                         alibaba::jsa::JSContext *context,
                         int callbackId,
                         const std::string& error,
                         int statusCode,
                         const std::string& body
                         );
}
}


#endif /* KRAKEN_FETCH_H */
