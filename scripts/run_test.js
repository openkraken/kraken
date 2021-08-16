/**
 * Test script
 */

require('./tasks');

const { series } = require('gulp');
const chalk = require('chalk');

series(
  'unit-test',
  'integration-test'
)(() => {
  console.log(chalk.green('Test Success.'));
});
