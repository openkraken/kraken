const { paths } = require('./tasks');
const { series, task } = require('gulp');
const chalk = require('chalk');
const { execSync } = require('child_process');

task('android-so-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/android`, { stdio: 'inherit' });
  done();
});

// Run tasks
series(
  'android-so-clean',
  'compile-polyfill',
  'build-android-kraken-lib'
)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
