/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

// https://github.com/ericf/css-mediaquery
const RE_MEDIA_QUERY = /^(?:(only|not)?\s*([_a-z][_a-z0-9-]*)|(\([^\)]+\)))(?:\s*and\s*(.*))?$/i;
const RE_MQ_EXPRESSION = /^\(\s*([_a-z-][_a-z0-9-]*)\s*(?:\:\s*([^\)]+))?\s*\)$/;
const RE_MQ_FEATURE = /^(?:(min|max)-)?(.+)/;

interface Expression {
  modifier: string;
  feature: string;
  value: string;
}

interface Query {
  inverse: boolean;
  type: string;
  expressions: Array<Expression>;
}

interface MediaQueryListEvent {
  readonly matches: boolean;
  readonly media: string;
}

interface MediaQueryList {
  readonly matches: boolean;
  readonly media: string;
  addListener(listener: ((ev: MediaQueryListEvent) => any) | null): void;
  removeListener(listener: ((ev: MediaQueryListEvent) => any) | null): void;
}

// Do not support media query list syntax like `screen, 3d-glasses, print and resolution > 90dpi`
function parseQuery(query: string): Query {

  var captures = query.trim().toLowerCase().match(RE_MEDIA_QUERY);

  // Media Query must be valid.
  if (!captures) {
    throw new SyntaxError('Invalid CSS media query: "' + query + '"');
  }

  let modifier = captures[1];
  let type = captures[2] || '';
  let expressions = ((captures[3] || '') + (captures[4] || '')).trim();

  let parsed: Query = {
    inverse: modifier === 'not',
    type,
    expressions: []
  };

  // Check for media query expressions.
  if (!expressions) {
    return parsed;
  }

  // Split expressions into a list.
  let expressionList = expressions.match(/\([^\)]+\)/g);

  // Media Query must be valid.
  if (!expressionList) {
    throw new SyntaxError('Invalid CSS media query: "' + query + '"');
  }

  parsed.expressions = expressionList.map(function (expression) {
    var captures = expression.match(RE_MQ_EXPRESSION);

    // Media Query must be valid.
    if (!captures) {
      throw new SyntaxError('Invalid CSS media query: "' + query + '"');
    }

    var feature = captures[1].match(RE_MQ_FEATURE) || [];

    return {
      modifier: feature[1] || '',
      feature: feature[2] || '',
      value: captures[2] || ''
    };
  });

  return parsed;
}

export function matchMedia(mediaQuery: string): MediaQueryList {

  let query = parseQuery(mediaQuery);
  // Not serialize the origin mediaquery
  let media = mediaQuery;
  let inverse = query.inverse;
  let _addListener: any;
  let _removeListener: any;

  // Only support one expression now
  let expression = query.expressions[0];
  let feature = expression.feature;
  let expValue = expression.value;
  let expMatches: boolean;
  let invalidFeature = false;

  switch (feature) {
    case 'prefers-color-scheme':
      _addListener = (listener: any) => {
        // FIXME: change listener will override by other media query, it's bug
        if (typeof listener == 'function') {
          // @ts-ignore
          window.onColorSchemeChange = () => {
            listener(matchMedia(mediaQuery));
          };
        }
      }
      _removeListener = () => {
        // @ts-ignore
        window.onColorSchemeChange = null;
      };
      // @ts-ignore
      expMatches = expValue === '' || window.colorScheme === expValue;
      break;
    default:
      // If query is invalid, serialized text should turn into "not all".
      media = 'not all';
      invalidFeature = true;
      expMatches = false;
  }

  if (!invalidFeature && inverse) {
    expMatches = !expMatches;
  }

  return {
    media,
    matches: expMatches,
    addListener(listener) {
      _addListener && _addListener(listener);
    },
    removeListener(listener) {
      _removeListener && _removeListener(listener);
    }
  }
}


