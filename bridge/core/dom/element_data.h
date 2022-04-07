/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_ELEMENT_DATA_H_
#define KRAKENBRIDGE_CORE_DOM_ELEMENT_DATA_H_

#include "bindings/qjs/atomic_string.h"

namespace kraken {

class ElementData {
 public:

 private:
  mutable Member<CSSPropertyValueSet> inline_style_;
  mutable SpaceSplitString class_names_;
  mutable AtomicString id_for_style_resolution_;
};

}

#endif  // KRAKENBRIDGE_CORE_DOM_ELEMENT_DATA_H_
