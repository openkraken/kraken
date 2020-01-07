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
const minimist = require('minimist');
const {createClient, upload} = require('./lib/alios');
const packageJSON = require('./package.json');

let enginePath = process.env.FLUTTER_ENGINE;
let platform = os.platform() === 'darwin' ? 'macos' : os.platform();
let buildMode = process.env.KRAKEN_BUILD || 'Debug';

const args = minimist(process.argv.slice(3));
const uploadToOSS = args['upload-to-oss'];

if (uploadToOSS) {
  if (!process.env.OSS_AK || !process.env.OSS_SK) {
    throw new Error('--ak and --sk is need to upload object into oss');
  }
}

if (!enginePath) {
  if (args['local-engine-path']) {
    enginePath = args['local-engine-path'];
  } else {
    throw new Error('you need to set FLUTTER_ENGINE env value or pass --local-engine-path <path> to the argv');
  }
}

const KRAKEN_ROOT = join(__dirname, '..');
const paths = {
  dist: resolve(__dirname, 'build'),
  distLib: resolve(__dirname, 'build/lib'),
  distInclude: resolve(__dirname, 'build/include'),
  distApp: resolve(__dirname, 'build/app'),
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
    if (fs.existsSync(path.join(__dirname, 'build.tar.gz'))) {
      execSync('rm build.tar.gz');
    }

    spawnSync('flutter', ['clean'], {
      cwd: paths.playground,
      env: process.env,
      stdio: 'inherit'
    });
  })
});

task('generate-cmake-files', (done) => {
  const args = [
    '-DCMAKE_BUILD_TYPE=Release',
    '-G',
    'CodeBlocks - Unix Makefiles',
    '-B',
    resolve(paths.bridge, 'cmake-build-release'),
    '-S',
    paths.bridge
  ];
  const handle = spawnSync('cmake', args, {
    cwd: paths.bridge,
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

task('generate-cmake-embedded-files', (done) => {
  const args = [
    '-DCMAKE_BUILD_TYPE=Release',
    '-G',
    'CodeBlocks - Unix Makefiles',
    '-B',
    resolve(paths.platform, 'linux_' + os.arch(), 'cmake-build-release'),
    '-S',
    resolve(paths.platform,'linux_' + os.arch())
  ];
  const handle = spawnSync('cmake', args, {
    cwd: path.join(paths.platform, 'linux_' + os.arch()),
    env: Object.assign(process.env),
    stdio: 'inherit',
  });
  if (handle.status !== 0) {
    console.error(handle.error);
    return done(false);
  }
  done(null);
});

task('build-kraken-embedded-lib', (done) => {
  const args = [
    '--build',
    resolve(paths.platform, 'linux_' + os.arch(), 'cmake-build-release'),
    '--target',
    'kraken_embbeder',
    '--',
    '-j',
    '4'
  ];
  const handle = spawnSync('cmake', args, {
    cwd: resolve(paths.platform, 'linux_' + os.arch()),
    env: process.env,
    stdio: 'inherit',
  });
  done(handle.status === 0 ? null : handle.error);
});

task('build-kraken-lib', (done) => {
  const args = [
    '--build',
    resolve(paths.bridge, 'cmake-build-release'),
    '--target',
    'kraken',
    '--',
    '-j',
    '4'
  ];
  mkdirp.sync(paths.distLib);
  const handle = spawnSync('cmake', args, {
    cwd: paths.bridge,
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

task('upload-dist', (done) => {
  execSync('tar -zcf ./build.tar.gz ./build', {
    cwd: __dirname
  });
  const client = createClient(process.env.OSS_AK, process.env.OSS_SK);
  upload(client, `kraken-cli-vendors/kraken-${os.platform()}-${packageJSON.version}.tar.gz`, path.join(__dirname, 'build.tar.gz')).then(() => {
    done()
  }).catch(err => done(err.message));
});

task('build-embedded-assets', (done) => {
  if (!fs.existsSync(paths.distInclude)) {
    fs.mkdirSync(paths.distInclude);
  }
  let copySource = [
    {
      src: paths.playground + '/linux/flutter/generated_plugin_registrant.h',
      dest: paths.distInclude + '/generated_plugin_registrant.h'
    },
    {
      src: paths.bridge + '/include/kraken_bridge_export.h',
      dest: paths.distInclude + '/kraken_bridge_export.h'
    },
    {
      src: paths.platform + '/linux_x64/kraken_embbeder.h',
      dest: paths.distInclude + '/kraken_embbeder.h'
    },
    {
      src: paths.playground + '/linux/flutter/ephemeral/flutter_export.h',
      dest: paths.distInclude + '/flutter_export.h'
    },
    {
      src: paths.playground + '/linux/flutter/ephemeral/flutter_glfw.h',
      dest: paths.distInclude + '/flutter_glfw.h'
    },
    {
      src: paths.playground + '/linux/flutter/ephemeral/flutter_messenger.h',
      dest: paths.distInclude + '/flutter_messenger.h'
    },
    {
      src: paths.playground + '/linux/flutter/ephemeral/flutter_plugin_registrar.h',
      dest: paths.distInclude + '/flutter_plugin_registrar.h'
    }
  ];

  for (let source of copySource) {
    fs.copyFileSync(source.src, source.dest);
  }

  execSync(`cp -r ${paths.playground}/linux/flutter/ephemeral/cpp_client_wrapper_glfw/include/flutter ${paths.distInclude}`);
  execSync(`ln -s ../app/lib/libflutter_linux_glfw.so ./`, {
    cwd: paths.distLib
  });
  execSync('chrpath -r "\$ORIGIN" ./libkraken.so', {
    cwd: paths.distLib
  });
  execSync('chrpath -r "\$ORIGIN ./libkraken_embbeder.so"', {
    cwd: paths.distLib
  });
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

let embeddedSeries = series(
  'generate-cmake-embedded-files',
  'build-kraken-embedded-lib',
  'build-embedded-assets'
);

exports.default = series(
  'clean',
  _series,
  'compile-polyfill',
  parallel('generate-cmake-files', 'build-kraken-lib', 'generate-shells'),
  platform === 'linux' ? embeddedSeries : [],
  uploadToOSS ? 'upload-dist' : []
);

