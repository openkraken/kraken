/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */


#ifndef KRAKENBRIDGE_HTML_PARSER_H
#define KRAKENBRIDGE_HTML_PARSER_H

#include "include/kraken_bridge.h"

namespace kraken::binding::jsc {
  std::unique_ptr<HTMLParser> createHTMLParser(std::unique_ptr<JSContext> &context, const JSExceptionHandler &handler, void *owner);
}

#endif // KRAKENBRIDGE_HTML_PARSER_H
