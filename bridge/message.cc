/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "message.h"

namespace kraken {
namespace message {

void Message::parseMessageBody(const std::string &body) {
  size_t start = 0;
  std::string key;
  size_t len = body.size();
  bool hasKey = false;

  for (size_t i = 0; i < len; i++) {
    char w = body[i];

    if (w == '=' && !hasKey) {
      key = body.substr(start, i - start);
      start = i + 1;
      hasKey = true;
      continue;
    }

    if (w == ';') {
      std::string &&value = body.substr(start, i - start);
      start = i + 1;
      hasKey = false;

      map_.set(key, value);
      continue;
    }
  }
}

void Message::readMessage(const std::string &key, std::string &value) {
  map_.get(key, value);
}

size_t Message::getBracketsValue(const std::string &source,
                                 std::string &value) {
  size_t start = 0;
  size_t len = source.size();
  for (size_t i = 0; i < len; i++) {
    char w = source[i];

    if (w == '[') {
      start = i + 1;
      continue;
    }

    if (w == ']') {
      value = source.substr(start, i - start);
      return i;
    }
  }

  return -1;
}

} // namespace message

} // namespace kraken
