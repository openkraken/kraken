/**
 * Benchmark script
 */

require('./tasks');
const { series } = require('gulp');
const chalk = require('chalk');

process.env.ENABLE_PROFILE = 'true';

series(
  'android-so-clean',
  'compile-polyfill',
  'build-android-webf-lib',
  'build-benchmark-app',
  'run-benchmark'
)(() => {
  console.log(chalk.green('Test Success.'));
});
