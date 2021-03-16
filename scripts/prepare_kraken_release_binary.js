require('./tasks');
const chalk = require('chalk');
const { series } = require('gulp');

series(
  'sdk-clean',
  'compile-polyfill',
  'build-darwin-kraken-lib',
  'build-ios-kraken-lib',
  'build-android-kraken-lib',
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
