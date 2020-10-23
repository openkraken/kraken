/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'package:kraken/css.dart';
import 'package:kraken/inspector.dart';

const String CSS_GET_COMPUTED_STYLE_FOR_NODE = 'CSS.getComputedStyleForNode';
const String CSS_GET_INLINE_STYLES_FOR_NODE = 'CSS.getInlineStylesForNode';
const String CSS_GET_MATCHED_STYLES_FOR_NODE = 'CSS.getMatchedStylesForNode';
const String CSS_STYLE_SHEET_CHANGED = 'CSS.styleSheetChanged';
const String CSS_SET_STYLE_TEXTS = 'CSS.setStyleTexts';

class InspectorCssAgent {
  InspectorDomAgent _domAgent;

  InspectorCssAgent(this._domAgent);

  ResponseState onRequest(Map<String, Object> params, String method, ResponseData responseData) {
    return ResponseState.Success;
  }

}
