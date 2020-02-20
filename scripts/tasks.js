const { src, dest, series, parallel, task } = require('gulp');
const mkdirp = require('mkdirp');
const path = require('path');
const { writeFileSync } = require('fs');
const { spawnSync, execSync } = require('child_process');
const { join, resolve } = require('path');
const chalk = require('chalk');
const fs = require('fs');
const del = require('del');
const os = require('os');
const minimist = require('minimist');

let enginePath = process.env.FLUTTER_ENGINE;
let platform = os.platform() === 'darwin' ? 'macos' : os.platform();
let buildMode = process.env.KRAKEN_BUILD || 'Debug';

const SUPPORTED_JS_ENGINES = ['jsc', 'v8'];
const V8_VERSION = '7.9.317.31';

const args = minimist(process.argv.slice(3));
const uploadToOSS = args['upload-to-oss'];

if (uploadToOSS) {
  if (!process.env.OSS_AK || !process.env.OSS_SK) {
    throw new Error('--ak and --sk is need to upload object into oss');
  }
}

const KRAKEN_ROOT = join(__dirname, '..');
const paths = {
  dist: resolve(__dirname, 'build'),
  distLib: resolve(__dirname, 'build/lib'),
  distInclude: resolve(__dirname, 'build/include'),
  distApp: resolve(__dirname, 'build/app'),
  cli: resolveKraken('cli'),
  app_launcher: resolveKraken('app_launcher'),
  platform: resolveKraken('platform'),
  kraken: resolveKraken('kraken'),
  bridge: resolveKraken('bridge'),
  polyfill: resolveKraken('bridge/polyfill'),
  thirdParty: resolveKraken('third_party'),
  devtools: resolveKraken('devtools'),
  tools: resolveKraken('cli/tools'),
  jsa: resolveKraken('jsa'),
};

function resolveKraken(submodule) {
  return resolve(KRAKEN_ROOT, submodule);
}

function buildKraken(platform, mode) {
  let runtimeMode = '--debug';
  if (mode === 'Release' && platform === 'macos') runtimeMode = '--release';
  if (mode === 'Profile' && platform === 'macos') runtimeMode = '--profile';

  const args = ['build', platform, runtimeMode];

  console.log(`${chalk.green('[BUILD]')} flutter ${args.join(' ')}`);
  const handle = spawnSync('flutter', args, {
    cwd: paths.app_launcher,
    env: process.env,
    stdio: 'inherit',
  });
  // Exit code.
  return handle.status;
}

task('build-kraken-debug', (done) => {
  const exitCode = buildKraken(platform, 'Debug', 'host_debug');
  if (exitCode === 0) {
    done();
  } else {
    done(chalk.red('BUILD KRAKEN DEBUG WITH ERROR.'));
  }
});

task('build-kraken-release', (done) => {
  const exitCode = buildKraken(platform, 'Release', 'host_release');
  if (exitCode === 0) {
    done();
  } else {
    done(chalk.red('BUILD KRAKEN RELEASE WITH ERROR.'));
  }
});

task('build-kraken-profile', (done) => {
  const exitCode = buildKraken(platform, 'Profile', 'host_profile');
  if (exitCode === 0) {
    done();
  } else {
    done(chalk.red('BUILD KRAKEN PROFILE WITH ERROR.'));
  }
});

task('copy-kraken-debug', (done) => {
  if (platform === 'macos') {
    execSync(`mkdir -p ${paths.dist}/app/debug`);
    // There is a problem that `cp -r` will drop symbolic, which will make app fails.
    execSync(`mv ${path.join(paths.app_launcher, 'build/macos/Build/Products/Debug/Kraken.app')} ${paths.dist}/app/debug`);
    return done();
  }

  if (platform === 'linux') {
    execSync(`mkdir -p ${paths.dist}/app`);
    execSync(`cp -r ${path.join(paths.app_launcher, 'build/linux/debug/*')} ./build/app`);
    return done();
  }

  throw new Error('Kraken debug is not supported in your platform.');
  // execSync(`cp -r ${path.join(paths.app_launcher, 'build/linux/Build/Products/Debug')} ./build/app/`);
});

task('copy-kraken-release', (done) => {
  if (platform === 'macos') {
    execSync(`mkdir -p ${paths.dist}/app/release`);
    execSync(`mv ${path.join(paths.app_launcher, 'build/macos/Build/Products/Release/Kraken.app')} ./build/app/release/`);
    return done();
  }

  if (platform === 'linux') {
    execSync(`mkdir -p ${paths.dist}/app`);
    execSync(`mv ${path.join(paths.app_launcher, 'build/linux/release/')} ./build/app`);
    return done();
  }

  throw new Error('Kraken release is not supported in your platform.');
});

task('copy-kraken-profile', (done) => {
  if (platform === 'macos') {
    execSync(`mkdir -p ${paths.dist}/app/profile`);
    execSync(`mv ${path.join(paths.app_launcher, 'build/macos/Build/Products/Profile/Kraken.app')} ./build/app/profile`);
    return done();
  }

  if (platform === 'linux') {
    execSync(`mkdir -p ${paths.dist}/app`);
    execSync(`mv ${path.join(paths.app_launcher, 'build/linux/profile/')} ./build/app`);
    return done();
  }

  throw new Error('Kraken profile is not supported in your platform.');
});

// Add a empty file to keep flutter_assets folder, or flutter crashed.
task('patch-kraken-release', (done) => {
  writeFileSync(join(paths.dist, 'app/release/Kraken.app/Contents/Frameworks/App.framework/Resources/flutter_assets/.keep'), '# Just keep it.');
  done();
});

task('patch-kraken-profile', (done) => {
  writeFileSync(join(paths.dist, 'app/release/Kraken.app/Contents/Frameworks/App.framework/Resources/flutter_assets/.keep'), '# Just keep it.');
  done();
});

task('clean', () => {
  execSync('git clean -xfd', {
    cwd: paths.app_launcher,
    env: process.env,
    stdio: 'inherit'
  });
  return del('build');
});

for (let jsEngine of SUPPORTED_JS_ENGINES) {
  task('generate-cmake-files-' + jsEngine, (done) => {
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
        KRAKEN_JS_ENGINE: jsEngine
      }),
      stdio: 'inherit',
    });
    if (handle.status !== 0) {
      console.error(handle.error);
      return done(false);
    }
    done(null);
  });

  task('build-kraken-lib-' + jsEngine, (done) => {
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
      env: Object.assign(process.env, {
        KRAKEN_JS_ENGINE: jsEngine
      }),
      stdio: 'inherit',
    });
    done(handle.status === 0 ? null : handle.error);
  });
}

task('generate-cmake-embedded-files', (done) => {
  const args = [
    '-DCMAKE_BUILD_TYPE=Release',
    '-G',
    'CodeBlocks - Unix Makefiles',
    '-B',
    resolve(paths.platform, 'linux_' + os.arch(), 'cmake-build-release'),
    '-S',
    resolve(paths.platform, 'linux_' + os.arch())
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

task('copy-build-libs', done => {
  execSync(`cp -r ${paths.thirdParty}/v8-${V8_VERSION}/lib/${platform}/ ${paths.distLib}`, {
    env: process.env,
    stdio: 'inherit'
  });
  execSync(`./tools/install_name_prefix_tool.sh ./build/lib /usr/local/opt/v8/libexec @executable_path/../Frameworks`, {
    env: process.env,
    cwd: paths.cli,
    stdio: 'inherit'
  });

  execSync(`mv ./build/lib/*.dylib ./build/app/${buildMode.toLowerCase()}/Kraken.app/Contents/Frameworks`, {
    env: process.env,
    cwd: paths.cli,
    stdio: 'inherit'
  });

  done();
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

  let result = spawnSync('npm', ['run', buildMode === 'Release' ? 'build:release' : 'build'], {
    cwd: paths.polyfill,
    env: process.env,
    stdio: 'inherit'
  });

  if (result.status !== 0) {
    return done(result.status);
  }

  result = spawnSync('node', [
    'js_to_c.js',
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

task('pub-get', (done) => {
  execSync('flutter pub get', {
    cwd: paths.app_launcher,
    env: process.env,
    stdio: 'inherit'
  });
  execSync('flutter pub get', {
    cwd: paths.kraken,
    env: process.env,
    stdio: 'inherit'
  });

  done();
});

task('upload-dist', (done) => {
  const filename = `kraken-${os.platform()}-${require('../cli/package.json').version}.tar.gz`;
  execSync(`tar -zcf ${paths.cli}/vendors/${filename} ./build`, {
    cwd: __dirname
  });
  const filepath = path.join(__dirname, 'vendors', filename);
  execSync(`node oss.js --ak ${process.env.OSS_AK} --sk ${process.env.OSS_SK} -s ${filepath} -n ${filename}`, {
    cwd: paths.tools,
    env: process.env,
    stdio: 'inherit'
  });
  done();
});

task('build-embedded-assets', (done) => {
  if (!fs.existsSync(paths.distInclude)) {
    fs.mkdirSync(paths.distInclude);
  }
  let copySource = [
    {
      src: paths.app_launcher + '/linux/flutter/generated_plugin_registrant.h',
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
      src: paths.app_launcher + '/linux/flutter/ephemeral/flutter_export.h',
      dest: paths.distInclude + '/flutter_export.h'
    },
    {
      src: paths.app_launcher + '/linux/flutter/ephemeral/flutter_glfw.h',
      dest: paths.distInclude + '/flutter_glfw.h'
    },
    {
      src: paths.app_launcher + '/linux/flutter/ephemeral/flutter_messenger.h',
      dest: paths.distInclude + '/flutter_messenger.h'
    },
    {
      src: paths.app_launcher + '/linux/flutter/ephemeral/flutter_plugin_registrar.h',
      dest: paths.distInclude + '/flutter_plugin_registrar.h'
    }
  ];

  for (let source of copySource) {
    fs.copyFileSync(source.src, source.dest);
  }

  execSync(`cp -r ${paths.app_launcher}/linux/flutter/ephemeral/cpp_client_wrapper_glfw/include/flutter ${paths.distInclude}`);
  execSync(`ln -s ../app/lib/libflutter_linux_glfw.so ./`, {
    cwd: paths.distLib,
    stdio: 'inherit'
  });
  execSync('chrpath -r "\\$ORIGIN" ./libkraken.so', {
    cwd: paths.distLib,
    stdio: 'inherit'
  });
  execSync('chrpath -r "\\$ORIGIN ./libkraken_embbeder.so"', {
    cwd: paths.distLib,
    stdio: 'inherit'
  });
  done();
});
