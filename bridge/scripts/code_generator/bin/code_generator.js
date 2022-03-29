#!/usr/bin/env node

const { program } = require('commander');
const packageJSON = require('../package.json');
const path = require('path');
const glob = require('glob');
const fs = require('fs');
const { IDLBlob } = require('../dist/idl/IDLBlob');
const { JSONBlob } = require('../dist/json/JSONBlob');
const { Template } = require('../dist/json/template');
const { analyzer } = require('../dist/idl/analyzer');
const { generateJSONTemplate } = require('../dist/json/generator');

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

function genCodeFromTypeDefine() {
  // Generate code from type defines.
  let files = glob.sync("**/*.d.ts", {
    cwd: source,
  });

  let blobs = files.map(file => {
    let filename = 'qjs_' + file.split('/').slice(-1)[0].replace('.d.ts', '');
    let implement = file.replace(path.join(__dirname, '../../')).replace('.d.ts', '');
    return new IDLBlob(path.join(source, file), dist, filename, implement);
  });

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
}

// Generate code from json data.
function genCodeFromJSONData() {
  let jsonFiles = glob.sync('**/*.json', {
    cwd: source
  });
  let templateFiles = glob.sync('**/*.tpl', {
    cwd: path.join(__dirname, '../static')
  });

  let blobs = jsonFiles.map(file => {
    let filename = file.split('/').slice(-1)[0].replace('.json', '');
    return new JSONBlob(path.join(source, file), dist, filename);
  });

  let templates = templateFiles.map(template => {
    let filename = template.split('/').slice(-1)[0].replace('.tpl', '');
    return new Template(path.join(path.join(__dirname, '../static'), template), filename);
  });

  for (let i = 0; i < blobs.length; i ++) {
    let blob = blobs[i];
    blob.json.metadata.templates.forEach((targetTemplate) => {
      let targetTemplateHeaderData = templates.find(t => t.filename === targetTemplate + '.h');
      let targetTemplateBodyData = templates.find(t => t.filename === targetTemplate + '.h');
      let result = generateJSONTemplate(blobs[i], targetTemplateHeaderData, targetTemplateBodyData);
      let dist = blob.dist;

      if (targetTemplate === 'qjs_atom') {
        dist = path.join(__dirname, '../../../third_party/quickjs')
      }

      let genFilePath = path.join(dist, blob.filename);
      fs.writeFileSync(genFilePath + '.h', result.header);
      result.source && fs.writeFileSync(genFilePath + '.cc', result.source);
    });
  }
}

// genCodeFromTypeDefine();
genCodeFromJSONData();
