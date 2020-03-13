/**
 * Test script
 */

require('./tasks');

const { series } = require('gulp');
const chalk = require('chalk');

series(
  'bridge-test',
  'patch-flutter-tester',
  'js-api-test',
  'integration-test'
)(() => {
  console.log(chalk.green('Test Success.'));
});
