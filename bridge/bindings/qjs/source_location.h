/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_SOURCE_LOCATION_H_
#define KRAKENBRIDGE_BINDINGS_QJS_SOURCE_LOCATION_H_

#include <memory>
#include <string>

namespace kraken {

class ExecutingContext;

class SourceLocation {
 public:
  // Zero lineNumber and columnNumber mean unknown. Captures current stack
  // trace.
  static std::unique_ptr<SourceLocation> Capture(const std::string& url, unsigned line_number, unsigned column_number);

  SourceLocation(const std::string& url, unsigned line_number, unsigned column_number);
  ~SourceLocation();

  const std::string& Url() const { return url_; }
  unsigned LineNumber() const { return line_number_; }
  unsigned ColumnNumber() const { return column_number_; }

 private:
  std::string url_;
  unsigned line_number_;
  unsigned column_number_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_SOURCE_LOCATION_H_
