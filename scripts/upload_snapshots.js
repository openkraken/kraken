const fs = require('fs');
const archiver = require('archiver');
const { series, task } = require('gulp');
const uploader = require('./utils/uploader');

const path = require('path');
const uuid = require('uuid').v4;
const chalk = require('chalk');

function createSnapshotArchiver(baseDir) {
  return new Promise((resolve, reject) => {
    const output = fs.createWriteStream(baseDir + '/snapshot.zip');
    const archive = archiver('zip', {
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

task('upload-snapshots', async (done) => {
  await createSnapshotArchiver(path.join(__dirname, '../'));
  const filename = uuid() + '.zip';
  uploader('snapshots/' + filename, path.join(__dirname, '../snapshot.zip')).then(() => {
    console.log('Snapshot Upload Success: https://kraken.oss-cn-hangzhou.aliyuncs.com/snapshots/' + filename);
    done();
  }).catch(err => done(err));
});

series(
  'upload-snapshots'
)(() => {
  console.log(chalk.green('Upload Success.'));
});
