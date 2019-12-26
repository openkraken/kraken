const {src, dest, series, parallel, task} = require('gulp');
const mkdirp = require('mkdirp');
const path = require('path');
const {writeFileSync} = require('fs');
const {spawnSync, execSync} = require('child_process');
const {join, resolve} = require('path');
const chalk = require('chalk');
const fs = require('fs');
const del = require('del');
const os = require('os');

let enginePath = process.env.FLUTTER_ENGINE;
let platform = os.platform() === 'darwin' ? 'macos' : os.platform();
let buildMode = process.env.KRAKEN_BUILD || 'Debug';

if (!enginePath) {
  let args = process.argv.slice(4);
  let index = args.indexOf('--local-engine-path');
  if (index >= 0) {
    enginePath = args[index + 1];
  } else {
    throw new Error('you need to set FLUTTER_ENGINE env value or pass --local-engine-path <path> to the argv');
  }
}

const KRAKEN_ROOT = join(__dirname, '..');
const paths = {
  dist: resolve(__dirname, 'build'),
  distLib: resolve(__dirname, 'build/lib'),
  cli: resolveKraken('cli'),
  playground: resolveKraken('playground'),
  platform: resolveKraken('platform'),
  dartfm: resolveKraken('dartfm'),
  bridge: resolveKraken('bridge'),
  polyfill: resolveKraken('bridge/polyfill'),
  devtools: resolveKraken('devtools'),
  tools: resolveKraken('cli/tools'),
  jsa: resolveKraken('jsa'),
  localEngineSrc: resolve(__dirname, enginePath),
};

function resolveKraken(submodule) {
  return resolve(KRAKEN_ROOT, submodule);
}

// enum KrakenBuildMode {
//   Debug,
//   Release,
// }
function buildKraken(platform, mode, localEngine, localEngineSrc) {
  let runtimeMode = '--debug';
  if (mode === 'Release' && platform === 'macos') runtimeMode = '--release';
  if (mode === 'Profile' && platform === 'macos') runtimeMode = '--profile';

  const args = ['build', platform, runtimeMode];

  if (localEngine) args.push(`--local-engine=${localEngine}`);
  if (localEngineSrc) args.push(`--local-engine-src-path=${localEngineSrc}`)
  console.log(`${chalk.green('[BUILD]')} flutter ${args.join(' ')}`);
  const handle = spawnSync('flutter', args, {
    cwd: paths.playground,
    env: process.env,
    stdio: 'inherit',
  });
  // Exit code.
  return handle.status;
}

task('build-kraken-debug', (done) => {
  const exitCode = buildKraken(platform, 'Debug', 'host_debug', paths.localEngineSrc);
  if (exitCode === 0) {
    done();
  } else {
    done(chalk.red('BUILD KRAKEN DEBUG WITH ERROR.'));
  }
});

task('build-kraken-release', (done) => {
  const exitCode = buildKraken(platform, 'Release', 'host_release', paths.localEngineSrc);
  if (exitCode === 0) {
    done();
  } else {
    done(chalk.red('BUILD KRAKEN RELEASE WITH ERROR.'));
  }
});

task('build-kraken-profile', (done) => {
  const exitCode = buildKraken(platform, 'Profile', 'host_profile', paths.localEngineSrc);
  if (exitCode === 0) {
    done();
  } else {
    done(chalk.red('BUILD KRAKEN PROFILE WITH ERROR.'));
  }
});

task('copy-kraken-debug', (done) => {
  if (platform === 'macos') {
    execSync(`mkdir -p ${paths.dist}/app`);
    // There is a problem that `cp -r` will drop symbolic, which will make app fails.
    execSync(`mv ${path.join(paths.playground, 'build/macos/Build/Products/Debug/Kraken.app')} ${paths.dist}/app/`);
    return done();
  }

  if (platform === 'linux') {
    execSync(`mkdir -p ${paths.dist}/app`);
    execSync(`cp -r ${path.join(paths.playground, 'build/linux/debug/*')} ./build/app`);
    return done();
  }

  throw new Error('Kraken debug is not supported in your platform.');
  // execSync(`cp -r ${path.join(paths.playground, 'build/linux/Build/Products/Debug')} ./build/app/`);
});

task('copy-kraken-release', (done) => {
  if (platform === 'macos') {
    execSync(`mkdir -p ${paths.dist}/app`);
    execSync(`mv ${path.join(paths.playground, 'build/macos/Build/Products/Release/Kraken.app')} ./build/app/`);
    return done();
  }

  if (platform === 'linux') {
    execSync(`mkdir -p ${paths.dist}/app`);
    execSync(`mv ${path.join(paths.playground, 'build/linux/release/')} ./build/app`);
    return done();
  }

  throw new Error('Kraken release is not supported in your platform.');
});

task('copy-kraken-profile', (done) => {
  if (platform === 'macos') {
    execSync(`mkdir -p ${paths.dist}/app`);
    execSync(`mv ${path.join(paths.playground, 'build/macos/Build/Products/Profile/Kraken.app')} ./build/app/`);
    return done();
  }

  if (platform === 'linux') {
    execSync(`mkdir -p ${paths.dist}/app`);
    execSync(`mv ${path.join(paths.playground, 'build/linux/profile/')} ./build/app`);
    return done();
  }

  throw new Error('Kraken profile is not supported in your platform.');
});

// Add a empty file to keep flutter_assets folder, or flutter crashed.
task('patch-kraken-release', (done) => {
  writeFileSync(join(paths.dist, 'app/Kraken.app/Contents/Frameworks/App.framework/Resources/flutter_assets/.keep'), '# Just keep it.');
  done();
});

task('patch-kraken-profile', (done) => {
  writeFileSync(join(paths.dist, 'app/Kraken.app/Contents/Frameworks/App.framework/Resources/flutter_assets/.keep'), '# Just keep it.');
  done();
});

task('clean', () => {
  return del('build').then(() => {
    spawnSync('flutter', ['clean'], {
      cwd: paths.playground,
      env: process.env,
      stdio: 'inherit'
    });
  })
});

task('generate-cmake-files', (done) => {
  let arch = os.arch();
  let dir;

  if (platform === 'linux') {
    dir = platform + '_' + arch;
  } else {
    dir = platform;
  }

  const args = [
    '-DCMAKE_BUILD_TYPE=Release',
    '-G',
    'CodeBlocks - Unix Makefiles',
    '-B',
    resolve(paths.platform, dir + '/cmake-build-release'),
    '-S',
    resolve(paths.platform, dir)
  ];
  const handle = spawnSync('cmake', args, {
    cwd: resolve(paths.platform, dir),
    env: Object.assign(process.env, {
      LIBRARY_OUTPUT_DIR: paths.distLib,
      FLUTTER_ENGINE: paths.localEngineSrc
    }),
    stdio: 'inherit',
  });
  if (handle.status !== 0) {
    console.error(handle.error);
    return done(false);
  }
  done(null);
});

task('build-kraken-lib', (done) => {
  let arch = os.arch();
  let dir;

  if (platform === 'linux') {
    dir = platform + '_' + arch;
  } else {
    dir = platform;
  }

  const args = [
    '--build',
    resolve(paths.platform, dir + '/cmake-build-release'),
    '--target',
    'kraken',
    '--',
    '-j',
    '4'
  ];
  mkdirp.sync(paths.distLib);
  const handle = spawnSync('cmake', args, {
    cwd: paths.platform,
    env: process.env,
    stdio: 'inherit',
  });
  done(handle.status === 0 ? null : handle.error);
});

task('generate-shells', () => {
  return src('./shell/**')
    .pipe(dest(paths.dist));
});

function runPolyFillNpmInstall() {
  spawnSync('npm', ['install'], {
    cwd: paths.polyfill,
    env: process.env,
    stdio: 'inherit'
  });
}

task('compile-polyfill', (done) => {
  if (!fs.existsSync(path.join(paths.polyfill, 'node_modules'))) {
    runPolyFillNpmInstall();
  }

  let result = spawnSync('npm', ['run', 'build'], {
    cwd: paths.polyfill,
    env: process.env,
    stdio: 'inherit'
  });

  if (result.status !== 0) {
    return done(result.status);
  }

  result = spawnSync('node', [
    'js2c.js',
    '-s',
    path.join(paths.polyfill, 'dist/main.js'),
    '-o',
    path.join(paths.polyfill, 'dist')
  ], {
    cwd: paths.tools,
    env: process.env,
    stdio: 'inherit'
  });

  if (result.status !== 0) {
    return done(result.status);
  }

  done();
});

let _series;

// linux only support debug from now on
if (platform === 'linux') {
  _series = series('build-kraken-debug', 'copy-kraken-debug'); // Debug too large to publish to npm.
} else {
  if (buildMode === 'Release') {
    _series = series('build-kraken-release', 'copy-kraken-release', 'patch-kraken-release');
  } else if (buildMode === 'Profile') {
    _series = series('build-kraken-profile', 'copy-kraken-profile', 'patch-kraken-profile');
  } else {
    _series = series('build-kraken-debug', 'copy-kraken-debug');
  }
}

exports.default = series(
  'clean',
  _series,
  'compile-polyfill',
  parallel('generate-cmake-files', 'build-kraken-lib', 'generate-shells'),
);

