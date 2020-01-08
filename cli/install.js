const packageJSON = require('./package.json');
const os = require('os');
const execSync = require('child_process').execSync;
const path = require('path');

const tarName = `kraken-${os.platform()}-${packageJSON.version}.tar.gz`;
const downloadUrl = `https://kraken.oss-cn-hangzhou.aliyuncs.com/kraken-cli-vendors/${tarName}`;

execSync(`wget ${downloadUrl}`, {
  cwd: __dirname,
  stdio: 'inherit'
});
execSync(`tar xzf ${path.join(__dirname, tarName)}`, {
  cwd: __dirname,
  stdio: 'inherit'
});
execSync(`rm ${tarName}`, {
  cwd: __dirname,
  stdio: 'inherit'
});
