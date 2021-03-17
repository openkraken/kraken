/**
 * Only build libkraken.dylib for macOS
 */
const { paths } = require('./tasks');
const { series, task } = require('gulp');
const chalk = require('chalk');
const { execSync } = require('child_process');

task('macos-dylib-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/macos`, { stdio: 'inherit' });
  done();
});

// Run tasks
series(
  'macos-dylib-clean',
  'compile-polyfill',
  'build-darwin-kraken-lib',
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
