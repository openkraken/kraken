const exec = require('child_process').execSync;
const fs = require('fs');
const path = require('path');

function getCurrentGitRev() {
  return exec('git rev-parse --short HEAD', {encoding: 'utf-8'}).trim();
}

function setPubVersion(version) {
  const pubSepcPath = path.join(__dirname, '../kraken/pubspec.yaml');
  const pubSpec = fs.readFileSync(pubSepcPath, {encoding: 'utf-8'})
  const replaced = pubSpec.replace(/version: ([\d\w.]+).+/, 'version: $1-nightly.' + version);

  fs.writeFileSync(pubSepcPath, replaced);
}


let currentGitRev = getCurrentGitRev();
setPubVersion(currentGitRev);
