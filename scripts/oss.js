const fs = require('fs');
const chalk = require('chalk');
const path = require('path');
const program = require('commander');
const OSS = require('ali-oss');
const packageJSON = require('../package.json');

program
  .version(packageJSON.version)
  .usage('[-s kraken-darwin.tar.gz]')
  .requiredOption('--ak <string>', 'your aliyun bucket AK')
  .requiredOption('--sk <string>', 'your aliyun bucket SK')
  .requiredOption('-s, --source <string>', 'the source file to be upload')
  .requiredOption('-n, --name <string>', 'file name').parse(process.argv);

function createClient(ak, sk) {
  return new OSS({
    region: 'oss-cn-hangzhou',
    accessKeyId: ak,
    accessKeySecret: sk,
    bucket: 'kraken'
  });
}

function upload(client, filename, filepath) {
  const readStream = fs.createReadStream(filepath);
  return client.put(filename, readStream).then((ret) => {
    if (ret.res.status !== 200) {
      return Promise.reject(chalk.red(`file: ${filename} upload failed !`));
    } else {
      return Promise.resolve();
    }
  });
}

let source = program.source;
if (!path.isAbsolute(source)) {
  source = path.join(process.cwd(), source);
}

const client = createClient(program.ak, program.sk);
console.log('[Tips]: Uploading', source);

upload(client, `kraken-cli-vendors/${program.name}`, source).then(() => {
  console.log(chalk.green('Uploaded successfully.'));
}).catch((err) => {
  throw err;
});
