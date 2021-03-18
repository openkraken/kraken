/**
 * Test script
 */

require('./tasks');

const { series } = require('gulp');
const chalk = require('chalk');

series(
  'macos-dylib-clean',
  'compile-polyfill',
  'build-darwin-kraken-lib',

  'integration-test'
)(() => {
  console.log(chalk.green('Test Success.'));
});
