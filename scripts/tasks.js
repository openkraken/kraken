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

const SUPPORTED_JS_ENGINES = ['jsc', 'v8'];
const V8_VERSION = '7.9.317.31';

const KRAKEN_ROOT = join(__dirname, '..');
const TARGET_PATH = join(KRAKEN_ROOT, 'targets');
const platform = os.platform();
const buildMode = process.env.KRAKEN_BUILD || 'Debug';
const targetDist = join(TARGET_PATH, platform, buildMode.toLowerCase());
const paths = {
  cli: resolveKraken('cli'),
  app_launcher: resolveKraken('app_launcher'),
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
  if (mode === 'Release' && platform === 'darwin') runtimeMode = '--release';

  const args = [
    'build',
    platform === 'darwin' ? 'macos' : platform,
    runtimeMode,
  ];

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

task('copy-kraken-debug', (done) => {
  const targetDist = join(TARGET_PATH, platform, 'debug');
  execSync(`mkdir -p ${targetDist}`);
  if (platform === 'darwin') {
    // There is a problem that `cp -r` will drop symbolic, which will make app fails.
    execSync(`mv ${path.join(paths.app_launcher, 'build/macos/Build/Products/Debug/Kraken.app')} ${targetDist}`);
    return done();
  }

  if (platform === 'linux') {
    execSync(`cp -r ${path.join(paths.app_launcher, 'build/linux/debug/*')} ${targetDist}`);
    return done();
  }

  throw new Error('Kraken debug is not supported in your platform.');
});


task('copy-kraken-release', (done) => {
  const targetDist = join(TARGET_PATH, platform, 'release');
  execSync(`mkdir -p ${targetDist}`);

  if (platform === 'darwin') {
    execSync(`mv ${path.join(paths.app_launcher, 'build/macos/Build/Products/Release/Kraken.app')} ${targetDist}`);
    // Add a empty file to keep flutter_assets folder, or flutter crashed.
    writeFileSync(join(targetDist, 'Kraken.app/Contents/Frameworks/App.framework/Resources/flutter_assets/.keep'), '# Just keep it.');
    return done();
  }

  if (platform === 'linux') {
    execSync(`mv ${path.join(paths.app_launcher, 'build/linux/release/')} ${targetDist}`);
    return done();
  }

  throw new Error('Kraken release is not supported in your platform.');
});

task('clean', () => {
  execSync('git clean -xfd', {
    cwd: paths.app_launcher,
    env: process.env,
    stdio: 'inherit'
  });

  if (buildMode === 'All') {
    return del(join(TARGET_PATH, platform));
  } else {
    return del(join(TARGET_PATH, platform, buildMode.toLowerCase()));
  }
});

const libOutputPath = join(TARGET_PATH, platform, buildMode.toLowerCase(), 'lib');
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
        LIBRARY_OUTPUT_DIR: libOutputPath,
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
    mkdirp.sync(libOutputPath);
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
  execSync(`cp -r ${paths.thirdParty}/v8-${V8_VERSION}/lib/${platform === 'darwin' ? 'macos' : platform}/ ${libOutputPath}`, {
    env: process.env,
    stdio: 'inherit'
  });

  execSync(`./install_name_prefix_tool.sh ${libOutputPath} /usr/local/opt/v8/libexec @executable_path/../Frameworks`, {
    env: process.env,
    cwd: __dirname,
    stdio: 'inherit'
  });

  execSync(`mv ${libOutputPath}/* ${targetDist}/Kraken.app/Contents/Frameworks`, {
    env: process.env,
    cwd: targetDist,
    stdio: 'inherit'
  });

  execSync(`rmdir ${libOutputPath}`);

  done();
});

task('compile-polyfill', (done) => {
  if (!fs.existsSync(path.join(paths.polyfill, 'node_modules'))) {
    spawnSync('npm', ['install'], {
      cwd: paths.polyfill,
      env: process.env,
      stdio: 'inherit'
    });
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
    cwd: __dirname,
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
  done()
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
  const distInclude = join(TARGET_PATH, 'linux', buildMode, 'include');
  if (!fs.existsSync(distInclude)) {
    fs.mkdirSync(distInclude);
  }
  let copySource = [
    {
      src: paths.app_launcher + '/linux/flutter/generated_plugin_registrant.h',
      dest: distInclude + '/generated_plugin_registrant.h'
    },
    {
      src: paths.bridge + '/include/kraken_bridge_export.h',
      dest: distInclude + '/kraken_bridge_export.h'
    },
    {
      src: paths.platform + '/linux_x64/kraken_embbeder.h',
      dest: distInclude + '/kraken_embbeder.h'
    },
    {
      src: paths.app_launcher + '/linux/flutter/ephemeral/flutter_export.h',
      dest: distInclude + '/flutter_export.h'
    },
    {
      src: paths.app_launcher + '/linux/flutter/ephemeral/flutter_glfw.h',
      dest: distInclude + '/flutter_glfw.h'
    },
    {
      src: paths.app_launcher + '/linux/flutter/ephemeral/flutter_messenger.h',
      dest: distInclude + '/flutter_messenger.h'
    },
    {
      src: paths.app_launcher + '/linux/flutter/ephemeral/flutter_plugin_registrar.h',
      dest: distInclude + '/flutter_plugin_registrar.h'
    }
  ];

  for (let source of copySource) {
    fs.copyFileSync(source.src, source.dest);
  }

  execSync(`cp -r ${paths.app_launcher}/linux/flutter/ephemeral/cpp_client_wrapper_glfw/include/flutter ${distInclude}`);
  execSync(`ln -s ../app/lib/libflutter_linux_glfw.so ./`, {
    cwd: libOutputPath,
    stdio: 'inherit'
  });
  execSync('chrpath -r "\\$ORIGIN" ./libkraken.so', {
    cwd: libOutputPath,
    stdio: 'inherit'
  });
  execSync('chrpath -r "\\$ORIGIN ./libkraken_embbeder.so"', {
    cwd: libOutputPath,
    stdio: 'inherit'
  });
  done();
});
