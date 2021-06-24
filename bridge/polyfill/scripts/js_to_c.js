const minimist = require('minimist');
const argv = minimist(process.argv.slice(2));
const path = require('path');
const fs = require('fs');

if (argv.help) {
  process.stdout.write(`Convert Javascript Code into Cpp source code
Usage: node js_to_c.js -s /path/to/source.js -o /path/to/dist.cc -n polyfill\n`);
  process.exit(0);
}

function strEncodeUTF16(str) {
  let buf = new ArrayBuffer(str.length*2);
  let bufView = new Uint16Array(buf);
  for (var i=0, strLen=str.length; i < strLen; i++) {
    bufView[i] = str.charCodeAt(i);
  }
  return bufView;
}

function strEncodeUTF8(str) {
  let bufView = new Uint8Array(Buffer.from(str));
  return bufView;
}


const getPolyFillHeader = (outputName) => `/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_${outputName.toUpperCase()}_H
#define KRAKEN_${outputName.toUpperCase()}_H

#if KRAKEN_JSC_ENGINE
#include "bridge_jsc.h"
#elif KRAKEN_QUICK_JS_ENGINE
#include "bridge_qjs.h"
#endif

void initKraken${outputName}(kraken::JSBridge *bridge);

#endif // KRAKEN_${outputName.toUpperCase()}_H
`;

const getPolyFillJavaScriptSource = (source) => {
  // const uint8Array = new Uint8Array(Buffer.from(source));
  let utf8BufferView = strEncodeUTF8(source);
  let utf16BufferView = strEncodeUTF16(source);
  if (process.env.KRAKEN_JS_ENGINE == 'quickjs') {
    return `
const uint32_t bufferLength = ${utf8BufferView.length};
static const uint8_t sourceBuffer[${utf8BufferView.length}] = { ${utf8BufferView.join(',')} };`
  } else {
    return `
const uint32_t bufferLength = ${utf16BufferView.length};
static const uint16_t sourceBuffer[${utf16BufferView.length}] = { ${utf16BufferView.join(',')} };`
  }
};

const getPolyFillSource = (source, outputName) => `/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "${outputName.toLowerCase()}.h"

${getPolyFillJavaScriptSource(source)}

void initKraken${outputName}(kraken::JSBridge *bridge) {
  bridge->evaluateScript(${process.env.KRAKEN_JS_ENGINE === 'quickjs' ? 'reinterpret_cast<const char *>(sourceBuffer)' : 'sourceBuffer'}, bufferLength, "internal://", 0);
}
`;

function convertJSToCpp(code, outputName) {
  code = code.replace(/\)\"/g, '))") + std::u16string(uR"("');
  return getPolyFillSource(code, outputName);
}

let source = argv.s;
let output = argv.o;
let outputName = argv.n || 'PolyFill';

if (!source || !output) {
  console.error('-s and -o params are required');
  process.exit(1);
}

function getAbsolutePath(p) {
  if (path.isAbsolute(p)) {
    return p;
  } else {
    return path.join(__dirname, p);
  }
}

let sourcePath = getAbsolutePath(source);
let outputPath = getAbsolutePath(output);

let jsCode = fs.readFileSync(sourcePath, {encoding: 'utf-8'});

let headerSource = getPolyFillHeader(outputName);
let ccSource = convertJSToCpp(jsCode, outputName);

fs.writeFileSync(path.join(outputPath, outputName.toLowerCase() + '.h'), headerSource);
fs.writeFileSync(path.join(outputPath, outputName.toLowerCase() + '.cc'), ccSource);
