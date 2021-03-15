/**
 * Only build libkraken.dylib for macOS
 */
require('./tasks');
const { series } = require('gulp');
const chalk = require('chalk');

// Run tasks
series(
  'sdk-clean',
  'compile-polyfill',
  'build-darwin-kraken-lib',
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
