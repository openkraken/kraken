/**
 * Build script for iOS
 */

require('./tasks');
const chalk = require('chalk');
const { program } = require('commander');
const minimist = require('minimist');
const { series, parallel } = require('gulp');
const buildMode = process.env.KRAKEN_BUILD || 'Debug';

// Run tasks
series(
  'sdk-clean',
  'compile-polyfill',
  'build-ios-kraken-lib'
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
