const exec = require('child_process').execSync;
const versionStr = exec('flutter --version', {encoding: 'utf-8'});
let group = versionStr.split('\n');

let flutter = group[0];
let framework = group[1];
let engine = group[2];
let dart = group[3];

let flutterVersion = flutter.split(' ')[1];
let frameworkVersion = framework.split(' ')[3];
let engineVersion = engine.split(' ')[3];
let dartVersion = dart.split(' ')[3];

let result = `${flutterVersion};${frameworkVersion};${engineVersion};${dartVersion}`;
process.stdout.write(result);