/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_LEGACY_SPACE_SPLIT_STRING_H_
#define KRAKENBRIDGE_CORE_DOM_LEGACY_SPACE_SPLIT_STRING_H_

#include <string>
#include <vector>

namespace kraken {

class SpaceSplitString {
 public:
  SpaceSplitString() = default;
  explicit SpaceSplitString(std::string string) { set(string); }

  void set(std::string& string);
  bool contains(std::string& string);
  bool containsAll(std::string s);

 private:
  static std::string delimiter_;
  std::vector<std::string> sz_data_;
};


}

#endif  // KRAKENBRIDGE_CORE_DOM_LEGACY_SPACE_SPLIT_STRING_H_
