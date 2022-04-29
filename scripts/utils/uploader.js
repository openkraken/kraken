const OSS = require('ali-oss');
const fs = require('fs');

function createClient(ak, sk) {
  return new OSS({
    region: 'oss-cn-hangzhou',
    accessKeyId: ak,
    accessKeySecret: sk,
    bucket: 'kraken'
  });
}

async function uploader(filename, filepath) {
  const client = createClient(process.env.OSS_AK, process.env.OSS_SK);
  
  return client.multipartUpload(filename, filepath, {
    parallel: 4,
    partSize: 1024 * 1024
  }).then((ret) => {
    if (ret.res.status !== 200) {
      return Promise.reject(chalk.red(`${filename}: alioss upload failed !`));
    } else {
      return Promise.resolve();
    }
  });
}

module.exports = uploader;
