/**
 * Build script for iOS
 */

const {paths, pkgVersion} = require('./tasks');
const chalk = require('chalk');
const minimist = require('minimist');
const archiver = require('archiver');
const fs = require('fs');
const path = require('path');
const { series, parallel, task } = require('gulp');

const SUPPORTED_JS_ENGINES = ['jsc'];
const buildMode = process.env.KRAKEN_BUILD || 'Debug';
const args = minimist(process.argv.slice(3));

task('pack-ios-framework', done => {
  const filename = `ios.sdk.${pkgVersion}.zip`;
  const filepath = path.join(paths.sdk, 'build/' + filename);
  const output = fs.createWriteStream(filepath);
  const archive = archiver('zip', {
    zlib: { level: 9 } // Sets the compression level.
  });
  archive.pipe(output);
  archive.directory(path.join(paths.sdk, 'build/ios/framework'), false);
  archive.finalize();

  output.on('close', function() {
    done();
  });
});

let buildAppTasks = series(
  'ios-framework-clean',
  'compile-polyfill',
  'build-ios-kraken-lib',
  'build-ios-frameworks',
  'pack-ios-framework'
);

// Run tasks
series(
  buildAppTasks,
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
