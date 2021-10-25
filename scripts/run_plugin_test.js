/**
 * Test script
 */

require('./tasks');

const { series } = require('gulp');
const chalk = require('chalk');

series(
  'plugin-test'
)(() => {
  console.log(chalk.green('Test Success.'));
});
