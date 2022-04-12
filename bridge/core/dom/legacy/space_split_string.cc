/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "space_split_string.h"

namespace kraken {

std::string SpaceSplitString::delimiter_{""};

void SpaceSplitString::set(std::string& string) {
  size_t pos = 0;
  std::string token;
  std::string s = string;
  while ((pos = s.find(delimiter_)) != std::string::npos) {
    token = s.substr(0, pos);
    sz_data_.push_back(token);
    s.erase(0, pos + delimiter_.length());
  }
  sz_data_.push_back(s);
}

bool SpaceSplitString::contains(std::string& string) {
  for (std::string& s : sz_data_) {
    if (s == string) {
      return true;
    }
  }
  return false;
}

bool SpaceSplitString::containsAll(std::string s) {
  std::vector<std::string> szData;
  size_t pos = 0;
  std::string token;

  while ((pos = s.find(delimiter_)) != std::string::npos) {
    token = s.substr(0, pos);
    szData.push_back(token);
    s.erase(0, pos + delimiter_.length());
  }
  szData.push_back(s);

  bool flag = true;
  for (std::string& str : szData) {
    bool isContains = false;
    for (std::string& data : sz_data_) {
      if (data == str) {
        isContains = true;
        break;
      }
    }
    flag &= isContains;
  }

  return flag;
}

}  // namespace kraken
