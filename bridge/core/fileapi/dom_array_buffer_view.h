/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOM_ARRAY_BUFFER_VIEW_H
#define KRAKENBRIDGE_DOM_ARRAY_BUFFER_VIEW_H

#include <typeinfo>

namespace kraken {

class DOMArrayBufferView {
 public:
  enum ViewType {
    kTypeInt8,
    kTypeUint8,
    kTypeUint8Clamped,
    kTypeInt16,
    kTypeUint16,
    kTypeInt32,
    kTypeUint32,
    kTypeFloat32,
    kTypeFloat64,
    kTypeBigInt64,
    kTypeBigUint64,
    kTypeDataView
  };

 private:
  uint8_t* buffer_;
  size_t length_;
  ViewType view_type_;
};

}

#endif  // KRAKENBRIDGE_DOM_ARRAY_BUFFER_VIEW_H
