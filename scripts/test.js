/**
 * Test script
 */

require('./tasks');

const { series, parallel } = require('gulp');
const chalk = require('chalk');

series(
  'bridge-test',
  'patch-flutter-tester',
  'jsApi-test'
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});