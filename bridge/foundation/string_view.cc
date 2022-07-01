/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "string_view.h"

namespace kraken {

StringView::StringView(const std::string& string) : bytes_(string.data()), length_(string.length()), is_8bit_(true) {}

StringView::StringView(const NativeString* string)
    : bytes_(string->string()), length_(string->length()), is_8bit_(false) {}

StringView::StringView(void* bytes, unsigned length, bool is_wide_char)
    : bytes_(bytes), length_(length), is_8bit_(!is_wide_char) {}
}  // namespace kraken
