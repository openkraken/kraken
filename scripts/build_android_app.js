/**
 * Build script for iOS
 */

require('./tasks');
const chalk = require('chalk');
const { series } = require('gulp');

// Run tasks
series(
  'compile-polyfill',
  'build-android-app',
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
