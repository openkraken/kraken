/**
 * Test script
 */

require('./tasks');

const { series } = require('gulp');
const chalk = require('chalk');

series(
  'integration-test'
)(() => {
  console.log(chalk.green('Test Success.'));
});
