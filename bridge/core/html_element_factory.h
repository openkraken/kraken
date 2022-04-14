/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_HTML_ELEMENT_FACTORY_H_
#define KRAKENBRIDGE_CORE_HTML_ELEMENT_FACTORY_H_

#include "bindings/qjs/atomic_string.h"

namespace kraken {

class Document;
class HTMLElement;

class HTMLElementFactory {
 public:
  // If |local_name| is unknown, nullptr is returned.
  static HTMLElement* Create(const AtomicString& local_name, Document&);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_HTML_ELEMENT_FACTORY_H_
