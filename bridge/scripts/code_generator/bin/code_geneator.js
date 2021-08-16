#!/usr/bin/env node

const { program } = require('commander');
const packageJSON = require('../package.json');
const path = require('path');
const glob = require('glob');
const { Blob } = require('../dist/blob');
const { analyzer } = require('../dist/analyzer');

program
  .version(packageJSON.version)
  .description('Kraken code generator.')
  .requiredOption('-s, --source <path>', 'source directory.')
  .requiredOption('-d, --dist <path>', 'destionation directory.')

program.parse(process.argv);

let {source, dist} = program.opts();

if (!path.isAbsolute(source)) {
  source = path.join(process.cwd(), source);
}
if (!path.isAbsolute(dist)) {
  dist = path.join(process.cwd(), dist);
}

let files = glob.sync("**/*.d.ts", {
  cwd: source,
});

let blobs = files.map(file => {
  let filename = file.replace('.d.ts', '');
  return new Blob(path.join(source, file), path.join(dist, filename), filename);
});

analyzer(blobs[0]);
