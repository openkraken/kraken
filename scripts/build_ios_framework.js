/**
 * Build script for iOS
 */

require('./tasks');
const chalk = require('chalk');
const { program } = require('commander');
const minimist = require('minimist');
const { series, parallel } = require('gulp');
const buildMode = process.env.KRAKEN_BUILD || 'Debug';

let buildAppTasks = series(
  'compile-polyfill',
  'build-ios-kraken-lib-release'
);

// Run tasks
series(
  'ios-clean',
  buildAppTasks,
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
