/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gtest/gtest.h"
#include <unordered_map>
#include "kraken_bridge.h"
#include "kraken_bridge_test.h"
#include "bridge_qjs.h"
#include "bridge_test_qjs.h"

TEST(TestFramework, init) {
  kraken::JSBridge *bridge = new kraken::JSBridge(0, [](int32_t contextId, const char* errmsg, void* data) {
    KRAKEN_LOG(VERBOSE) << errmsg;
  });
  kraken::JSBridgeTest *bridgeTest = new kraken::JSBridgeTest(bridge);

  std::string testCode = std::string(R"(


/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
/******/ })
/************************************************************************/
/******/ ({

/***/ "./node_modules/webpack/buildin/global.js":
/*!***********************************!*\
  !*** (webpack)/buildin/global.js ***!
  \***********************************/
/*! no static exports found */
/***/ (function(module, exports) {

var g;

// This works in non-strict mode
g = (function() {
	return this;
})();

try {
	// This works if eval is allowed (see CSP)
	g = g || new Function("return this")();
} catch (e) {
	// This works if the window reference is available
	if (typeof window === "object") g = window;
}

// g can still be undefined, but nothing to do about it...
// We return undefined, instead of nothing here, so it's
// easier to handle this case. if(!global) { ...}

module.exports = g;


/***/ }),

/***/ "./runtime/global.ts":
/*!***************************!*\
  !*** ./runtime/global.ts ***!
  \***************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

/* WEBPACK VAR INJECTION */(function(global) {/**
 * This file will expose global functions for specs to use.
 *
 * - setElementStyle: Apply style object to a specfic DOM.
 * - setElementProps: Apply attrs object to a specfic DOM.
 * - sleep: wait for several seconds.
 * - create: create element.
 * - snapshot: match snapshot of body's image.
 */
// Should by getter because body will reset before each spec
Object.defineProperty(global, 'BODY', {
  get() {
    return document.body;
  }

});

function setElementStyle(dom, object) {
  if (object == null) return;

  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

function setAttributes(dom, object) {
  for (const key in object) {
    if (object.hasOwnProperty(key)) {
      dom.setAttribute(key, object[key]);
    }
  }
}

function sleep(second) {
  return new Promise(done => setTimeout(done, second * 1000));
}

function setElementProps(el, props) {
  let keys = Object.keys(props);

  for (let key of keys) {
    if (key === 'style') {
      setElementStyle(el, props[key]);
    } else {
      el[key] = props[key];
    }
  }
}

function createElement(tag, props, child) {
  const el = document.createElement(tag);
  setElementProps(el, props);

  if (Array.isArray(child)) {
    child.forEach(c => el.appendChild(c));
  } else if (child) {
    el.appendChild(child);
  }

  return el;
}

function createElementWithStyle(tag, style, child) {
  const el = document.createElement(tag);
  setElementStyle(el, style);

  if (Array.isArray(child)) {
    child.forEach(c => el.appendChild(c));
  } else if (child) {
    el.appendChild(child);
  }

  return el;
}

function createViewElement(extraStyle, child) {
  return createElement('div', {
    style: {
      display: 'flex',
      position: 'relative',
      flexDirection: 'column',
      flexShrink: 0,
      alignContent: 'flex-start',
      border: '0 solid black',
      margin: 0,
      padding: 0,
      minWidth: 0,
      ...extraStyle
    }
  }, child);
}

function createText(content) {
  return document.createTextNode(content);
}

class Cubic {
  /// The x coordinate of the first control point.
  ///
  /// The line through the point (0, 0) and the first control point is tangent
  /// to the curve at the point (0, 0).
  /// The y coordinate of the first control point.
  ///
  /// The line through the point (0, 0) and the first control point is tangent
  /// to the curve at the point (0, 0).
  /// The x coordinate of the second control point.
  ///
  /// The line through the point (1, 1) and the second control point is tangent
  /// to the curve at the point (1, 1).
  /// The y coordinate of the second control point.
  ///
  /// The line through the point (1, 1) and the second control point is tangent
  /// to the curve at the point (1, 1).
  constructor(a, b, c, d) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
  }

  _evaluateCubic(a, b, m) {
    return 3 * a * (1 - m) * (1 - m) * m + 3 * b * (1 - m) * m * m + m * m * m;
  }

  transformInternal(t) {
    let start = 0.0;
    let end = 1.0;

    while (true) {
      let midpoint = (start + end) / 2;

      let estimate = this._evaluateCubic(this.a, this.c, midpoint);

      if (Math.abs(t - estimate) < 0.001) return this._evaluateCubic(this.b, this.d, midpoint);
      if (estimate < t) start = midpoint;else end = midpoint;
    }
  }

}

const ease = new Cubic(0.25, 0.1, 0.25, 1.0); // Simulate an mouse click action

async function simulateClick(x, y, pointer = 0) {
  await simulatePointer([[x, y, PointerChange.down], [x, y, PointerChange.up]], pointer);
} // Simulate an mouse swipe action.


async function simulateSwipe(startX, startY, endX, endY, duration, pointer = 0) {
  let params = [[startX, startY, PointerChange.down]];
  let pointerMoveDelay = 0.001;
  let totalCount = duration / pointerMoveDelay;
  let diffXPerSecond = (endX - startX) / totalCount;
  let diffYPerSecond = (endY - startY) / totalCount;

  for (let i = 0; i < totalCount; i++) {
    let progress = i / totalCount;
    let diffX = diffXPerSecond * 100 * ease.transformInternal(progress);
    let diffY = diffYPerSecond * 100 * ease.transformInternal(progress);
    ;
    await sleep(pointerMoveDelay);
    params.push([startX + diffX, startY + diffY, PointerChange.move]);
  }

  params.push([endX, endY, PointerChange.up]);
  ;
  await simulatePointer(params, pointer);
} // Simulate an point down action.


async function simulatePointDown(x, y, pointer = 0) {
  await simulatePointer([[x, y, PointerChange.down]], pointer);
} // Simulate an point up action.


async function simulatePoinrUp(x, y, pointer = 0) {
  await simulatePointer([[x, y, PointerChange.up]], pointer);
}

function append(parent, child) {
  parent.appendChild(child);
}

async function snapshot(target, filename) {
  if (target && target.toBlob) {
    ;
    await expectAsync(target.toBlob(1.0)).toMatchSnapshot(filename);
  } else {
    if (typeof target == 'number') {
      ;
      await sleep(target);
    }

    ;
    await expectAsync(document.documentElement.toBlob(1.0)).toMatchSnapshot(filename);
  }
} // Compatible to tests that use global variables.


Object.assign(global, {
  append,
  setAttributes,
  createElement,
  createElementWithStyle,
  createText,
  createViewElement,
  setElementStyle,
  setElementProps,
  simulateSwipe,
  simulateClick,
  sleep,
  snapshot,
  simulatePointDown,
  simulatePoinrUp
});
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./../node_modules/webpack/buildin/global.js */ "./node_modules/webpack/buildin/global.js")))

/***/ }),

/***/ "./runtime/reset.ts":
/*!**************************!*\
  !*** ./runtime/reset.ts ***!
  \**************************/
/*! no static exports found */
/***/ (function(module, exports) {

// For the snapshot image with white background, the default is transparent
document.documentElement.style.backgroundColor = 'white';

/***/ }),

/***/ 0:
/*!**********************************************!*\
  !*** multi ./runtime/reset ./runtime/global ***!
  \**********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

__webpack_require__(/*! /Users/andycall/work/kraken/integration_tests/runtime/reset */"./runtime/reset.ts");
module.exports = __webpack_require__(/*! /Users/andycall/work/kraken/integration_tests/runtime/global */"./runtime/global.ts");


/***/ })

/******/ });

)");

  bridge->evaluateScript(testCode.c_str(), testCode.size(), "test://", 0);

  auto fn = [](int32_t contextId, NativeString *status) -> void * {
    return nullptr;
  };
  bridgeTest->invokeExecuteTest(fn);
  delete bridgeTest;
  delete bridge;
}
