const OSS = require('ali-oss');
const fs = require('fs');
const chalk = require('chalk');

exports.createClient = function createClient(ak, sk) {
  return new OSS({
    region: 'oss-cn-hangzhou',
    accessKeyId: ak,
    accessKeySecret: sk,
    bucket: 'kraken'
  });
};

exports.upload = function upload(client, filename, filepath) {
  const readStream = fs.createReadStream(filepath);
  return client.put(filename, readStream).then(ret => {
    let res = ret.res;
    if (res.status !== 200) {
      return Promise.reject(chalk.red(`file: ${filename} upload failed !`));
    }

    return Promise.resolve();
  });
};
