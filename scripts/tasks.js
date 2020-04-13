const { src, dest, series, parallel, task } = require('gulp');
const mkdirp = require('mkdirp');
const rimraf = require('rimraf');
const path = require('path');
const { readFileSync, writeFileSync, mkdirSync } = require('fs');
const { spawnSync, execSync, fork } = require('child_process');
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
  targets: resolveKraken('targets'),
  scripts: resolveKraken('scripts'),
  app_launcher: resolveKraken('app_launcher'),
  kraken: resolveKraken('kraken'),
  bridge: resolveKraken('bridge'),
  polyfill: resolveKraken('bridge/polyfill'),
  thirdParty: resolveKraken('third_party'),
  devtools: resolveKraken('devtools'),
  tests: resolveKraken('tests'),
  sdk: resolveKraken('sdk')
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
    execSync(`mv ${path.join(paths.app_launcher, 'build/macos/Build/Products/Debug/app_launcher.app')} ${targetDist}`);
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
    execSync(`mv ${path.join(paths.app_launcher, 'build/macos/Build/Products/Release/app_launcher.app')} ${targetDist}`);
    // Add a empty file to keep flutter_assets folder, or flutter crashed.
    writeFileSync(join(targetDist, 'app_launcher.app/Contents/Frameworks/App.framework/Resources/flutter_assets/.keep'), '# Just keep it.');
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

const libOutputPath = join(TARGET_PATH, platform, 'lib');
for (let jsEngine of SUPPORTED_JS_ENGINES) {
  task('generate-cmake-files-' + jsEngine, (done) => {
    function generateCmake(args) {
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
    }

    const makeFileArgs = [
      '-DCMAKE_BUILD_TYPE=' + buildMode,
      '-DENABLE_TEST=true',
      '-G',
      'CodeBlocks - Unix Makefiles',
      '-B',
      resolve(paths.bridge, 'cmake-build-' + buildMode.toLowerCase()),
      '-S',
      paths.bridge
    ];

    // generate xcode project for debugging on macOS.
    if (platform === 'darwin') {
      const xcodeArgs = [
        '-DCMAKE_BUILD_TYPE=' + buildMode,
        '-G',
        'Xcode',
        '-B',
        resolve(paths.bridge, 'cmake-build-macos'),
        '-S',
        paths.bridge
      ];
      generateCmake(xcodeArgs);
    }

    generateCmake(makeFileArgs);
    done(null);
  });

  task('build-kraken-lib-' + jsEngine, (done) => {
    const args = [
      '--build',
      resolve(paths.bridge, 'cmake-build-' + buildMode.toLowerCase()),
      '--target',
      'kraken',
      'kom_test',
      'jsa_test_' + jsEngine,
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
    '-DCMAKE_BUILD_TYPE=' + buildMode,
    '-G',
    'CodeBlocks - Unix Makefiles',
    '-B',
    resolve(paths.platform, 'linux_' + os.arch(), 'cmake-build-' + buildMode.toLowerCase()),
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
    resolve(paths.platform, 'linux_' + os.arch(), 'cmake-build-' + buildMode.toLowerCase()),
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

task('copy-build-libs', (done) => {
  execSync(`cp -r ${paths.thirdParty}/v8-${V8_VERSION}/lib/${platform === 'darwin' ? 'macos' : platform}/ ${libOutputPath}`, {
    env: process.env,
    stdio: 'inherit'
  });

  done();
});

task('compile-polyfill', (done) => {
  if (!fs.existsSync(path.join(paths.polyfill, 'node_modules'))) {
    spawnSync('npm', ['install'], {
      cwd: paths.polyfill,
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

task('pack', (done) => {
  const { version } = require(join(paths.cli, 'package.json'));
  const filename = `kraken-${platform}-${version}.tar.gz`;
  const fileFullPath = join(paths.targets, filename);
  const source = join(paths.targets, platform);
  // Make sure packed file not exists.
  rimraf.sync(fileFullPath);

  try {
    // Ignore lib files, which is already copied to app shared frameworks.
    execSync(`tar --exclude ./${platform}/lib -zcvf ${filename} ./${platform}`, {
      cwd: paths.targets,
      stdio: 'inherit',
    });
    done();
  } catch (err) {
    done(err.message);
  }
});

task('upload', (done) => {
  const { version } = require(join(paths.cli, 'package.json'));
  const filename = `kraken-${platform}-${version}.tar.gz`;
  const fileFullPath = join(paths.targets, filename);
  execSync(`node oss.js --ak ${process.env.OSS_AK} --sk ${process.env.OSS_SK} -s ${fileFullPath} -n ${filename}`, {
    cwd: paths.scripts,
    stdio: 'inherit'
  });
  done();
});

task('bridge-test', (done) => {
  if (platform === 'darwin') {
    execSync(`${libOutputPath}/jsa_test_v8`, { stdio: 'inherit' });
  }
  execSync(`${libOutputPath}/jsa_test_jsc`, { stdio: 'inherit' });
  execSync(`${libOutputPath}/kom_test`, { stdio: 'inherit' });
  done();
});

task('integration-test', (done) => {
  const { status } = spawnSync('npm', ['run', 'test'], {
    stdio: 'inherit',
    cwd: paths.tests
  });
  if (status !== 0) {
    console.error('Run intefration test with error.');
    process.exit(status);
  } else {
    done();
  }
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

task('ios-clean', (done) => {
  execSync(`rm -rf ${paths.sdk}/build`, { stdio: 'inherit' });
  done();
});

['Debug', 'Release'].forEach(mode => {
  task(`build-ios-kraken-lib-${mode.toLowerCase()}`, (done) => {
    let buildInSDKs = JSON.parse(execSync('xcodebuild -showsdks -json', {
      encoding: 'utf-8'
    }));
    let iphoneSDK = buildInSDKs.find((info) => {
      return info.platform === 'iphoneos';
    });
    let simulatorSDK = buildInSDKs.find((info) => {
      return info.platform === 'iphonesimulator';
    });

    if (!iphoneSDK) {
      throw new Error('No suitable iOS SDK found');
    }

    if (!simulatorSDK) {
      throw new Error('No suitable iOS simulator found');
    }

    execSync(`xcodebuild -scheme libkraken build -target kraken -sdk ${simulatorSDK.canonicalName} -configuration ${mode} ONLY_ACTIVE_ARCH=NO TARGET_BUILD_DIR=../../sdk/build/ios/libkraken/${mode.toLowerCase()}/iossimulator`, {
      cwd: path.join(paths.bridge, 'ios'),
      stdio: 'inherit'
    });
    execSync(`xcodebuild -scheme libkraken build -target libkraken -sdk ${iphoneSDK.canonicalName} ONLY_ACTIVE_ARCH=NO -configuration ${mode} TARGET_BUILD_DIR=../../sdk/build/ios/libkraken/${mode.toLowerCase()}/ios`, {
      cwd: path.join(paths.bridge, 'ios'),
      stdio: 'inherit'
    });
    execSync(`codesign --remove-signature ${paths.sdk}/build/ios/libkraken/${mode.toLowerCase()}/ios/kraken.framework`, {
      stdio: 'inherit'
    });
    const targetPath = `${paths.sdk}/build/ios/framework/${mode}`;
    const frameworkPath = `${targetPath}/kraken.framework`;
    const plistPath = path.join(paths.scripts, 'support/kraken.plist');
    mkdirp.sync(frameworkPath);
    execSync(`lipo -create ./${mode.toLowerCase()}/ios/kraken.framework/kraken ./${mode.toLowerCase()}/iossimulator/kraken.framework/kraken -output ${frameworkPath}/kraken`, {
      cwd: path.join(paths.sdk, 'build/ios/libkraken'),
      stdio: 'inherit'
    });
    execSync(`cp ${plistPath} ${frameworkPath}/Info.plist`);
    const podspecContent = readFileSync(path.join(paths.scripts, 'support/KrakenSDK.podspec'), 'utf-8');
    const pkgVersion = readFileSync(path.join(paths.kraken, 'pubspec.yaml'), 'utf-8').match(/version: (.*)/)[1].trim();
    writeFileSync(
      `${targetPath}/KrakenSDK.podspec`,
      podspecContent.replace('@VERSION@', `${pkgVersion}-${mode.toLowerCase()}`),
      'utf-8'
    );
    execSync(`pod ipc spec KrakenSDK.podspec > KrakenSDK.podspec.json`, { cwd: targetPath });
    done();
  });
});

task(`build-ios-kraken-lib-profile`, done => {
  let frameworkSource = `${paths.sdk}/build/ios/framework/Release/kraken.framework`;
  let frameworkDest = `${paths.sdk}/build/ios/framework/Profile/kraken.framework`;
  execSync(`cp -r ${frameworkSource} ${frameworkDest}`);
  done();
});

task('build-ios-frameworks', (done) => {
  let cmd = `flutter build ios-framework`;
  execSync(cmd, {
    env: process.env,
    cwd: paths.sdk,
    stdio: 'inherit'
  });
  done();
});
