/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_FILEAPI_ARRAY_BUFFER_DATA_H_
#define KRAKENBRIDGE_CORE_FILEAPI_ARRAY_BUFFER_DATA_H_

namespace kraken {

struct ArrayBufferData {
  uint8_t* buffer;
  int32_t length;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_FILEAPI_ARRAY_BUFFER_DATA_H_
