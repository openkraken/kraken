const minimist = require('minimist');
const argv = minimist(process.argv.slice(2));
const path = require('path');
const fs = require('fs');

if (argv.help) {
  process.stdout.write(`Convert Javascript Code into Cpp source code
Usage: node js_to_c.js -s /path/to/source.js -o /path/to/dist.cc -n polyfill\n`);
  process.exit(0);
}

const getPolyFillHeader = (outputName) => `/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKEN_${outputName.toUpperCase()}_H
#define KRAKEN_${outputName.toUpperCase()}_H

#ifdef KRAKEN_ENABLE_JSA
#include "bridge_jsa.h"
#elif KRAKEN_JSC_ENGINE
#include "bridge_jsc.h"
#endif

void initKraken${outputName}(kraken::JSBridge *bridge);

#endif // KRAKEN_${outputName.toUpperCase()}_H
`;

const getPolyFillSource = (source, outputName) => `/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "${outputName.toLowerCase()}.h"

static std::u16string jsCode = std::u16string(uR"(${source})");

void initKraken${outputName}(kraken::JSBridge *bridge) {
  bridge->evaluateScript(jsCode, "internal://", 0);
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
