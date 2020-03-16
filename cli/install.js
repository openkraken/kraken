const { execSync } = require('child_process');
const os = require('os');
const path = require('path');
const packageJSON = require('./package.json');

const tarName = `kraken-${os.platform()}-${packageJSON.version}.tar.gz`;
const downloadUrl = `https://kraken.oss-cn-hangzhou.aliyuncs.com/kraken-cli-vendors/${tarName}`;

const processOptions = {
  cwd: __dirname,
  stdio: 'inherit'
};
execSync(`curl -O ${downloadUrl}`, processOptions);
execSync('mkdir build', processOptions);
execSync(`tar xzf ${path.join(__dirname, tarName)} -C ./build`, processOptions);
execSync(`rm ${tarName}`, processOptions);
