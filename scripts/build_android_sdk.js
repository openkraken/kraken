/**
 * Build script for iOS
 */

const { paths, pkgVersion } = require('./tasks');
const chalk = require('chalk');
const path = require('path');
const fs = require('fs');
const archiver = require('archiver');
const { series, task } = require('gulp');

task('pack-android-sdk', done => {
  const filename = `com.openkraken.kraken.sdk.${pkgVersion}.zip`;
  const filepath = path.join(paths.sdk, 'build/' + filename);
  const output = fs.createWriteStream(filepath);
  const archive = archiver('zip', {
    zlib: { level: 9 } // Sets the compression level.
  });
  archive.pipe(output);
  archive.directory(path.join(paths.sdk, 'build/host'), false);
  archive.finalize();

  output.on('close', function() {
    done();
  });
});

// Run tasks
series(
  'android-so-clean',
  'compile-polyfill',
  'build-android-kraken-lib',
  'build-android-sdk',
  'pack-android-sdk'
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
