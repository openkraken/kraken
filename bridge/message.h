/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_MESSAGE_H
#define KRAKEN_MESSAGE_H

#include "bindings/thread_safe_map.h"

namespace kraken {
namespace message {

/// This is a simple character processing library designed to handle strings in
/// a specific format, only supporting ascii encoding. don't use it to parse
/// string which contains Chinese character. message string format:
/// [key]=[value]
class Message {
  ThreadSafeMap<std::string, std::string> map_;

public:
  static size_t getBracketsValue(const std::string &str, std::string &value);

  void parseMessageBody(const std::string &body);
  void readMessage(const std::string &key, std::string &value);
};

} // namespace message
} // namespace kraken

#endif // KRAKEN_MESSAGE_H
