require('./tasks');
const chalk = require('chalk');
const minimist = require('minimist');
const { series, parallel } = require('gulp');

series(
  'compile-polyfill',
  'build-darwin-kraken-lib-release',
  'build-ios-kraken-lib-release',
  'build-android-kraken-lib-release',
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});