/**
 * Build script for iOS
 */

const { paths } = require('./tasks');
const chalk = require('chalk');
const { program } = require('commander');
const minimist = require('minimist');
const { series, parallel, task } = require('gulp');
const { execSync } = require('child_process');
const buildMode = process.env.KRAKEN_BUILD || 'Debug';

// Run tasks
series(
  'ios-framework-clean',
  'compile-polyfill',
  'build-ios-kraken-lib'
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
