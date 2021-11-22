/**
 * Build script for Linux
 */
require('./tasks');
const { series, parallel } = require('gulp');
const chalk = require('chalk');

// Run tasks
series(
  'clean',
  'compile-polyfill',
  'build-linux-kraken-lib'
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));  }
});
