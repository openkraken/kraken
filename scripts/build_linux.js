/**
 * Build script for Linux
 */
require('./tasks');
const { series } = require('gulp');

// Linux only support debug from now on
const buildLibKrakenTasks = series('build-kraken-debug', 'copy-kraken-debug'); // Debug too large to publish to npm.

// Run tasks
series(
  'clean',
  'pub-get',
  buildLibKrakenTasks,
  'compile-polyfill',
  parallel(
    'generate-cmake-files',
    'build-kraken-lib',
    'generate-shells'
  ),
  series(
    'generate-cmake-embedded-files',
    'build-kraken-embedded-lib',
    'build-embedded-assets'
  ),
  uploadToOSS ? 'upload-dist' : []
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
