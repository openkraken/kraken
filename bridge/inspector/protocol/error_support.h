/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_ERROR_SUPPORT_H
#define KRAKEN_DEBUGGER_ERROR_SUPPORT_H

#include <string>
#include <vector>

namespace kraken::debugger {
class ErrorSupport {
public:
  ErrorSupport();
  ~ErrorSupport();

  void push();
  void setName(const char *);
  void setName(const std::string &);
  void pop();
  void addError(const char *);
  void addError(const std::string &);
  bool hasErrors();
  std::string errors();

private:
  std::vector<std::string> m_path;
  std::vector<std::string> m_errors;
};
} // namespace kraken

#endif // KRAKEN_DEBUGGER_ERROR_SUPPORT_H
