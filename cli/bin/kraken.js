#!/usr/bin/env node

const program = require('commander');
const chalk = require('chalk');
const { spawnSync } = require('child_process');
const { join, resolve } = require('path');
const packageInfo = require('../package.json');
const os = require('os');
const fs = require('fs');
const temp = require('temp');

program
  .version(packageInfo.version)
  .usage('[-b bundlePath] [-u bundleURL] [-s source]')
  .description('Start a kraken app. Usage: ')
  .option('-b --bundle <bundle>', 'Bundle path. One of bundle or url is needed, if both determined, bundlePath will be used.')
  .option('-u --url <url>', 'Bundle url. One of bundle or url is needed, if both determined, bundlePath will be used.')
  .option('-s, --source <source>', 'Source code. pass source directory from command line')
  .option('-m --runtime-mode <runtimeMode>', 'Runtime mode, debug | release.', 'release')
  .option('--enable-kraken-js-log', 'print kraken js to dart log', false)
  .action((options) => {
    const { bundle, url, source } = options;

    if (!bundle && !url && !source) {
      program.help();
    } else {
      const env = Object.assign({}, process.env);
      const shellPath = getShellPath(options.runtimeMode);
      env['KRAKEN_LIBRARY_PATH'] = resolve(__dirname, '../build/lib');

      if (options.enableKrakenJsLog) {
        env['ENABLE_KRAKEN_JS_LOG'] = 'true';
      }

      if (bundle) {
        const absoluteBundlePath = resolve(process.cwd(), bundle);
        env['KRAKEN_BUNDLE_PATH'] = absoluteBundlePath;
      } else if (url) {
        env['KRAKEN_BUNDLE_URL'] = url;
      } else if (source) {
        let t = temp.track();
        let tempdir = t.openSync('source');
        let tempPath = tempdir.path;
        fs.writeFileSync(tempPath, source, {encoding: 'utf-8'});
        env['KRAKEN_BUNDLE_PATH'] = tempPath;
      }

      console.log(chalk.green('Execute binary:'), shellPath, '\n');
      spawnSync(shellPath, [], {
        stdio: 'inherit',
        env,
      });
    }
  });

program.parse(process.argv);

function getShellPath(runtimeMode) {
  const appPath = join(__dirname, '../build/app');
  const platform = os.platform();
  if (runtimeMode === 'release' && platform === 'darwin') {
    return join(appPath, 'Kraken.app/Contents/MacOS/Kraken');
  } else if (platform === 'linux') {
    return join(appPath, 'kraken');
  } else {
    console.log(chalk.red('[ERROR]: Debug binary too large, please manually build it.'));
    console.log(chalk.red('[ERROR]: Or contact @zhuoling.lcl'));
    process.exit(1);
  }
}
