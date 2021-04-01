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

task('ios-framework-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/ios`, { stdio: 'inherit' });
  done();
});

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
