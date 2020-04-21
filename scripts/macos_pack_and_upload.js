/**
 * Build script for Linux
 */
require('./tasks');
const chalk = require('chalk');
const { series } = require('gulp');

// Run tasks
series('macos-pack', 'macos-upload')((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
