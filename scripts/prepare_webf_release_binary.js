require('./tasks');
const chalk = require('chalk');
const { series } = require('gulp');
const os = require('os');

let buildTasks = [
  'sdk-clean',
  'compile-polyfill',
  'build-android-webf-lib',
];

if (os.platform() == 'win32') {
  // TODO: add windows support
  buildTasks.push(

  );
} else if (os.platform() == 'darwin') {
  buildTasks.push(
    'macos-dylib-clean',
    'build-darwin-webf-lib',
    'ios-framework-clean',
    'build-ios-webf-lib',
  );
} else if (os.platform() == 'linux') {
  buildTasks.push(
    'build-linux-webf-lib'
  )
}

series(buildTasks)((err) => {
  if (err) {
    console.log(err);
  } else {
    console.log(chalk.green('Success.'));
  }
});
