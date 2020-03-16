/**
 * Build script for Linux
 */
require('./tasks');
const { series, parallel } = require('gulp');

// Linux only support debug from now on
const buildLibKrakenTasks = series('build-kraken-debug', 'copy-kraken-debug'); // Debug too large to publish to npm.

const args = minimist(process.argv.slice(3));
const uploadToOSS = args['upload-to-oss'];

if (uploadToOSS) {
  if (!process.env.OSS_AK || !process.env.OSS_SK) {
    throw new Error('--ak and --sk is need to upload object into oss');
  }
}


// Run tasks
series(
  'clean',
  'pub-get',
  buildLibKrakenTasks,
  'compile-polyfill',
  parallel(
    'generate-cmake-files',
    'build-kraken-lib'
  ),
  series(
    'generate-cmake-embedded-files',
    'build-kraken-embedded-lib',
    'build-embedded-assets'
  ),
  uploadToOSS ? ['pack', 'upload'] : []
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
