/**
 * Build script for iOS
 */

require('./tasks');
const chalk = require('chalk');
const minimist = require('minimist');
const { series, parallel } = require('gulp');

const SUPPORTED_JS_ENGINES = ['jsc'];
const buildMode = process.env.KRAKEN_BUILD || 'Debug';
const args = minimist(process.argv.slice(3));

let buildAppTasks = series(
  'build-ios-frameworks',
  'build-ios-kraken-lib-debug',
  'build-ios-kraken-lib-release',
  'build-ios-kraken-lib-profile',
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
