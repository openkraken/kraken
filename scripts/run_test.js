/**
 * Test script
 */

require('./tasks');

const { series } = require('gulp');
const chalk = require('chalk');

series(
  'run-bridge-unit-test',
  'unit-test',
  'unit-test-coverage-reporter',
  'integration-test'
)(() => {
  console.log(chalk.green('Test Success.'));
});
