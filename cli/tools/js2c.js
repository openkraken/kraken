const minimist = require('minimist');
const argv = minimist(process.argv.slice(2));
const path = require('path');
const fs = require('fs');

if (argv.help) {
  process.stdout.write(`Convert Javascript Code into Cpp source code
Usage: node js2c.js -s /path/to/source.js -o /path/to/dist.c\n`);
  process.exit(0);
}

const getPolyFillHeader = () => `/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_POLYFILL_H
#define KRAKEN_POLYFILL_H

#include "bridge.h"

void initKrakenPolyFill(alibaba::jsa::JSContext *context);

#endif // KRAKEN_POLYFILL_H
`;

const getPolyFillSource = (source) => `/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "polyfill.h"

static const char* jsCode = R"(${source})";

void initKrakenPolyFill(alibaba::jsa::JSContext *context) {
  context->evaluateJavaScript(jsCode, "internal://", 0);
}
`;

function convertJSToCpp(code) {
  return getPolyFillSource(code);
}

let source = argv.s;
let output = argv.o;

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

let headerSource = getPolyFillHeader();
let ccSource = convertJSToCpp(jsCode);

fs.writeFileSync(path.join(outputPath, 'polyfill.h'), headerSource);
fs.writeFileSync(path.join(outputPath, 'polyfill.cc'), ccSource);

console.log('convert success!');
