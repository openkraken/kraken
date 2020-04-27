/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

// CSS Values and Units: https://drafts.csswg.org/css-values-3/#common-keywords

/// All of these keywords are normatively defined in the Cascade module.
enum CSSWideKeywords {
  /// The initial keyword represents the value specified as the property’s
  /// initial value.
  initial,

  /// The inherit keyword represents the computed value of the property on
  /// the element’s parent.
  inherit,

  /// The unset keyword acts as either inherit or initial, depending on whether
  /// the property is inherited or not.
  unset,
}