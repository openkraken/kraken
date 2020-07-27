/**
 * Build script for macOS
 */
require('./tasks');
const chalk = require('chalk');
const minimist = require('minimist');
const { series, parallel } = require('gulp');

const SUPPORTED_JS_ENGINES = ['jsc'];
const buildMode = process.env.KRAKEN_BUILD || 'Debug';
const args = minimist(process.argv.slice(3));
const uploadToOSS = args['upload-to-oss'];

if (uploadToOSS) {
  if (!process.env.OSS_AK || !process.env.OSS_SK) {
    throw new Error('--ak and --sk is need to upload object into oss');
  }
}

let buildAppTasks;
if (buildMode === 'Release') {
  buildAppTasks = series(
    'build-kraken-release',
    'copy-kraken-release'
  );
} else if (buildMode === 'All') {
  buildAppTasks = series(
    'build-kraken-release',
    'copy-kraken-release',
    'build-kraken-debug',
    'copy-kraken-debug'
  );
} else {
  buildAppTasks = series(
    'build-kraken-debug',
    'copy-kraken-debug'
  );
}

const libKrakenSeries = SUPPORTED_JS_ENGINES.map(jsEngine => [
  'generate-cmake-files-' + jsEngine,
  'build-kraken-lib-' + jsEngine
]);

// Run tasks
series(
  'clean',
  'pub-get',
  'compile-polyfill',
  libKrakenSeries,
  'copy-build-libs',
  buildAppTasks,
  uploadToOSS ? ['pack', 'upload'] : []
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
