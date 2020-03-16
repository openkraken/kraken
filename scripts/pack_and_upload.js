/**
 * Build script for Linux
 */
require('./tasks');
const chalk = require('chalk');
const { series } = require('gulp');

// Run tasks
series('pack', 'upload')((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
