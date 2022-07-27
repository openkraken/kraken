const exec = require("child_process").execSync;
const fs = require("fs");
const path = require("path");
const prependFile = require('prepend-file');

function getCurrentGitRev() {
  return exec("git rev-parse --short HEAD", { encoding: "utf-8" }).trim();
}

function setPubVersion(version) {
  const pubSepcPath = path.join(__dirname, "../kraken/pubspec.yaml");
  const pubSpec = fs.readFileSync(pubSepcPath, { encoding: "utf-8" });
  const replaced = pubSpec.replace(
    /version: ([\d\w.+]+)/,
    "version: $1-nightly." + version
  );

  fs.writeFileSync(pubSepcPath, replaced);

  return replaced;
}

function setChangeLog(version) {
  const pubSepcPath = path.join(__dirname, "../kraken/pubspec.yaml");
  const pubSpec = fs.readFileSync(pubSepcPath, { encoding: "utf-8" });
  const baseVersion = pubSpec.match(
    /version: ([\d\w.+]+)/,
  );

  const changeLogpath = path.join(__dirname, '../kraken/CHANGELOG.md');
  prependFile(changeLogpath, `## ${baseVersion[1]}-nightly.${version}
nightly version.
`);
}

function getDate() {
  var today = new Date();
  var dd = String(today.getDate()).padStart(2, "0");
  var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
  var yyyy = today.getFullYear();

  return mm + "-" + dd + "-" + yyyy;
}

let nightlyVersion = getDate() + '-' + getCurrentGitRev();

setPubVersion(nightlyVersion);
setChangeLog(nightlyVersion);
