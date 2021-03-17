const fs = require('fs');
const archiver = require('archiver');
const { src, dest, series, parallel, task } = require('gulp');
const OSS = require('ali-oss');
const path = require('path');
const uuid = require('uuid').v4;
const chalk = require('chalk');

function createSnapshotArchiver(baseDir) {
  return new Promise((resolve, reject) => {
    var output = fs.createWriteStream(baseDir + '/snapshot.zip');
    var archive = archiver('zip', {
      zlib: { level: 9 } // Sets the compression level.
    });

    output.on('close', function () {
      resolve();
    });

    output.on('end', function () {
    });

    // good practice to catch warnings (ie stat failures and other non-blocking errors)
    archive.on('warning', function (err) {
      if (err.code === 'ENOENT') {
        console.log(err);
      } else {
        reject(err);
      }
    });

    // good practice to catch this error explicitly
    archive.on('error', function (err) {
      reject(err);
    });

    archive.pipe(output);
    archive.directory(path.join(baseDir, 'integration_tests/snapshots'), false);

    archive.finalize();
  });
}

function createClient(ak, sk) {
  return new OSS({
    region: 'oss-cn-hangzhou',
    accessKeyId: ak,
    accessKeySecret: sk,
    bucket: 'kraken'
  });
}


function upload(filename, filepath) {
  const readStream = fs.createReadStream(filepath);
  return client.put(filename, readStream).then((ret) => {
    if (ret.res.status !== 200) {
      return Promise.reject(chalk.red(`${filename}: alioss upload failed !`));
    } else {
      return Promise.resolve();
    }
  });
}

const client = createClient(process.env.OSS_AK, process.env.OSS_SK);

task('upload-snapshots', async (done) => {
  await createSnapshotArchiver(path.join(__dirname, '../'));
  const filename = uuid() + '.zip';
  upload('snapshots/' + filename, path.join(__dirname, '../snapshot.zip')).then(() => {
    console.log('Snapshot Upload Success: https://kraken.oss-cn-hangzhou.aliyuncs.com/snapshots/' + filename);
    done();
  }).catch(err => done(err));
});

series(
  'upload-snapshots'
)(() => {
  console.log(chalk.green('Upload Success.'));
});
