/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "source_location.h"

namespace kraken {

std::unique_ptr<SourceLocation> SourceLocation::Capture(const std::string& url,
                                                        unsigned int line_number,
                                                        unsigned int column_number) {
  return std::make_unique<SourceLocation>(url, line_number, column_number);
}

SourceLocation::SourceLocation(const std::string& url, unsigned int line_number, unsigned int column_number)
    : url_(url), line_number_(line_number), column_number_(column_number) {}

}  // namespace kraken
