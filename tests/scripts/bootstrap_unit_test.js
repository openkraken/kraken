/**
 * Bootstrap flutter test to work.
 */
const glob = require('glob');
const chalk = require('chalk');
const { resolve } = require('path');
const { spawnSync } = require('child_process');

const testRoot = resolve(__dirname, '..');
const unitRoot = resolve(testRoot, 'unit');
const globOptions = {
  cwd: unitRoot,
  // Not search dot files.
  dot: false,
  // Follow symlinks.
  follow: true,
  // Return absolute path.
  absolute: false,
};

glob('**/*.dart', globOptions, function (err, files) {
  if (err) throw err;

  let resultStatus = 0;
  const failedTests = [];

  for (let i = 0; i < files.length; i++) {
    const filename = files[i];
    console.log(chalk.green('[Kraken Unit]: Run', filename));
    const childProcess = spawnSync('flutter', [
      'test',
      resolve(unitRoot, filename)
    ], { stdio: 'inherit' });
    resultStatus |= childProcess.status;
    if (childProcess.status > 0) {
      failedTests.push(filename);
    }
  }

  if (resultStatus > 0) {
    console.log();
    console.log(chalk.red('FAILED TESTS: '));
    console.log(failedTests.map(msg => '    ' + chalk.red(msg)).join('\n'));
    console.log();

    process.exit(1);
  } else {
    console.log(chalk.green('[Kraken Unit]: ALL TEST GROUP PASSED.'));
  }
});