#!/usr/bin/env node

const { program } = require('commander');
const packageJSON = require('../package.json');
const path = require('path');
const glob = require('glob');
const fs = require('fs');
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
  let filename = 'qjs_' + file.split('/').slice(-1)[0].replace('.d.ts', '');
  let implement = file.replace(path.join(__dirname, '../../')).replace('.d.ts', '');
  return new Blob(path.join(source, file), dist, filename, implement);
}).filter(blob => blob.filename === 'qjs_blob');

for (let i = 0; i < blobs.length; i ++) {
  let b = blobs[i];
  let result = analyzer(b);

  if (!fs.existsSync(b.dist)) {
    fs.mkdirSync(b.dist, {recursive: true});
  }

  let genFilePath = path.join(b.dist, b.filename);

  fs.writeFileSync(genFilePath + '.h', result.header);
  fs.writeFileSync(genFilePath + '.cc', result.source);
}

