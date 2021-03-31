/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "error_support.h"
#include <sstream>

namespace kraken::debugger {
ErrorSupport::ErrorSupport() {}
ErrorSupport::~ErrorSupport() {}

void ErrorSupport::setName(const char *name) {
  setName(std::string(name));
}

void ErrorSupport::setName(const std::string &name) {
  if (m_path.size() > 0) {
    m_path[m_path.size() - 1] = name;
  }
}

void ErrorSupport::push() {
  m_path.push_back(std::string());
}

void ErrorSupport::addError(const char *error) {
  addError(std::string(error));
}

void ErrorSupport::addError(const std::string &error) {
  std::stringstream builder;
  for (size_t i = 0; i < m_path.size(); ++i) {
    if (i) {
      builder << '.';
    }
    builder << m_path[i];
  }
  builder << ": ";
  builder << error;
  m_errors.push_back(builder.str());
  builder.str("");
}

std::string ErrorSupport::errors() {
  std::stringstream builder;
  for (size_t i = 0; i < m_errors.size(); ++i) {
    if (i) {
      builder << "; ";
    }
    builder << m_errors[i];
  }
  std::string result = builder.str();
  builder.str("");
  return result;
}

bool ErrorSupport::hasErrors() {
  return m_errors.size() != 0;
}

void ErrorSupport::pop() {
  m_path.pop_back();
}
} // namespace kraken
