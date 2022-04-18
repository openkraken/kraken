/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "space_split_string.h"

namespace kraken {

std::string SpaceSplitString::m_delimiter{" "};

void SpaceSplitString::set(std::string& string) {
  size_t pos = 0;
  std::string token;
  std::string s = string;
  while ((pos = s.find(m_delimiter)) != std::string::npos) {
    token = s.substr(0, pos);
    m_szData.push_back(token);
    s.erase(0, pos + m_delimiter.length());
  }
  m_szData.push_back(s);
}

bool SpaceSplitString::contains(std::string& string) {
  for (std::string& s : m_szData) {
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

  while ((pos = s.find(m_delimiter)) != std::string::npos) {
    token = s.substr(0, pos);
    szData.push_back(token);
    s.erase(0, pos + m_delimiter.length());
  }
  szData.push_back(s);

  bool flag = true;
  for (std::string& str : szData) {
    bool isContains = false;
    for (std::string& data : m_szData) {
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
