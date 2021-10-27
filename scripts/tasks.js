const { src, dest, series, parallel, task } = require('gulp');
const mkdirp = require('mkdirp');
const path = require('path');
const { readFileSync, writeFileSync, mkdirSync } = require('fs');
const { spawnSync, execSync, fork, spawn, exec } = require('child_process');
const { join, resolve } = require('path');
const { program } = require('commander');
const chalk = require('chalk');
const fs = require('fs');
const del = require('del');
const os = require('os');

program
.option('-e, --js-engine <engine>', 'The JavaScript Engine kraken used', 'jsc')
.option('--built-with-debug-jsc', 'Built bridge binary with debuggable JSC.')
.parse(process.argv);

const SUPPORTED_JS_ENGINES = ['jsc', 'quickjs'];

if (SUPPORTED_JS_ENGINES.indexOf(program.jsEngine) < 0) {
  throw new Error('Unsupported js engine:' + program.jsEngine);
}

const KRAKEN_ROOT = join(__dirname, '..');
const TARGET_PATH = join(KRAKEN_ROOT, 'targets');
const platform = os.platform();
const buildMode = process.env.KRAKEN_BUILD || 'Debug';
const paths = {
  targets: resolveKraken('targets'),
  scripts: resolveKraken('scripts'),
  example: resolveKraken('kraken/example'),
  kraken: resolveKraken('kraken'),
  bridge: resolveKraken('bridge'),
  polyfill: resolveKraken('bridge/polyfill'),
  thirdParty: resolveKraken('third_party'),
  tests: resolveKraken('integration_tests'),
  sdk: resolveKraken('sdk'),
  templates: resolveKraken('scripts/templates'),
  performanceTests: resolveKraken('performance_tests')
};

const pkgVersion = readFileSync(path.join(paths.kraken, 'pubspec.yaml'), 'utf-8').match(/version: (.*)/)[1].trim();
const isProfile = process.env.ENABLE_PROFILE === 'true';

exports.paths = paths;
exports.pkgVersion = pkgVersion;

let winShell = null;
if (platform == 'win32') {
  winShell = path.join(process.env.ProgramW6432, '\\Git\\bin\\bash.exe');

  if (!fs.existsSync(winShell)) {
    return done(new Error(`Can not location bash.exe, Please install Git for Windows at ${process.env.ProgramW6432}. \n https://git-scm.com/download/win`));
  }
}

function resolveKraken(submodule) {
  return resolve(KRAKEN_ROOT, submodule);
}

function buildKraken(platform, mode) {
  let runtimeMode = '--debug';
  if (mode === 'Release' && platform === 'darwin') runtimeMode = '--release';
  let main = path.join(paths.kraken, 'lib/cli.dart');
  const args = [
    'build',
    platform === 'darwin' ? 'macos' : platform,
    `--target=${main}`,
    runtimeMode,
  ];

  console.log(`${chalk.green('[BUILD]')} flutter ${args.join(' ')}`);
  const handle = spawnSync('flutter', args, {
    cwd: paths.example,
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
    execSync(`mv ${path.join(paths.example, 'build/macos/Build/Products/Debug/kraken_example.app')} ${targetDist}`);
    return done();
  }

  if (platform === 'linux') {
    execSync(`cp -r ${path.join(paths.example, 'build/linux/debug/*')} ${targetDist}`);
    return done();
  }

  throw new Error('Kraken debug is not supported in your platform.');
});


task('copy-kraken-release', (done) => {
  const targetDist = join(TARGET_PATH, platform, 'release');
  execSync(`mkdir -p ${targetDist}`);

  if (platform === 'darwin') {
    execSync(`mv ${path.join(paths.example, 'build/macos/Build/Products/Release/kraken_example.app')} ${targetDist}`);
    // Add a empty file to keep flutter_assets folder, or flutter crashed.
    writeFileSync(join(targetDist, 'kraken_example.app/Contents/Frameworks/App.framework/Resources/flutter_assets/.keep'), '# Just keep it.');
    return done();
  }

  if (platform === 'linux') {
    execSync(`mv ${path.join(paths.example, 'build/linux/release/')} ${targetDist}`);
    return done();
  }

  throw new Error('Kraken release is not supported in your platform.');
});

task('clean', () => {
  execSync('git clean -xfd', {
    cwd: paths.example,
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

function findDebugJSEngine(platform) {
  if (platform == 'macos' || platform == 'ios') {
    let packageConfigFilePath = path.join(paths.kraken, '.dart_tool/package_config.json');

    if (!fs.existsSync(packageConfigFilePath)) {
      execSync('flutter pub get', {
        cwd: paths.kraken,
        stdio: 'inherit'
      });
    }

    let packageConfig = require(packageConfigFilePath);
    let packages = packageConfig.packages;

    let jscPackageInfo = packages.find((i) => i.name === 'jsc');
    if (!jscPackageInfo) {
      throw new Error('Can not locate `jsc` dart package, please add jsc deps before build kraken libs.');
    }

    let rootUri = jscPackageInfo.rootUri;
    let jscPackageLocation = path.join(paths.kraken, '.dart_tool', rootUri);
    return path.join(jscPackageLocation, platform, 'JavaScriptCore.framework');
  }
}

task('build-darwin-kraken-lib', done => {
  let buildType = 'Debug';
  if (process.env.KRAKEN_BUILD === 'Release') {
    buildType = 'RelWithDebInfo';
  }

  let builtWithDebugJsc = program.jsEngine === 'jsc' && !!program.builtWithDebugJsc;

  let externCmakeArgs = [];

  if (isProfile) {
    externCmakeArgs.push('-DENABLE_PROFILE=TRUE');
  }

  if (builtWithDebugJsc) {
    let debugJsEngine = findDebugJSEngine(platform == 'darwin' ? 'macos' : platform);
    externCmakeArgs.push(`-DDEBUG_JSC_ENGINE=${debugJsEngine}`)
  }

  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} -DENABLE_TEST=true ${externCmakeArgs.join(' ')} \
    -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-macos-x86_64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      KRAKEN_JS_ENGINE: program.jsEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/macos/lib/x86_64')
    }
  });

  execSync(`cmake --build ${paths.bridge}/cmake-build-macos-x86_64 --target kraken kraken_test -- -j 12`, {
    stdio: 'inherit'
  });

  const binaryPath = path.join(paths.bridge, `build/macos/lib/x86_64/libkraken_${program.jsEngine}.dylib`);

  execSync(`install_name_tool -change /System/Library/Frameworks/JavaScriptCore.framework/Versions/A/JavaScriptCore @rpath/JavaScriptCore.framework/Versions/A/JavaScriptCore ${binaryPath}`);
  if (buildMode == 'Release' || buildMode == 'RelWithDebInfo') {
    execSync(`dsymutil ${binaryPath}`, { stdio: 'inherit' });
    execSync(`strip -S -X -x ${binaryPath}`, { stdio: 'inherit' });
  }

  done();
});

task('compile-polyfill', (done) => {
  if (!fs.existsSync(path.join(paths.polyfill, 'node_modules'))) {
    spawnSync('npm', ['install'], {
      cwd: paths.polyfill,
      stdio: 'inherit'
    });
  }

  let result = spawnSync('npm', ['run', (buildMode === 'Release' || buildMode === 'RelWithDebInfo') ? 'build:release' : 'build'], {
    cwd: paths.polyfill,
    env: {
      ...process.env,
      KRAKEN_JS_ENGINE: program.jsEngine
    },
    stdio: 'inherit'
  });

  if (result.status !== 0) {
    return done(result.status);
  }

  done();
});


function matchError(errmsg) {
  return errmsg.match(/(Failed assertion|\sexception\s|Dart\nError)/i);
}

task('integration-test', (done) => {
  const childProcess = spawn('npm', ['run', 'test'], {
    stdio: 'pipe',
    cwd: paths.tests
  });

  let stdout = '';

  childProcess.stderr.pipe(process.stderr);
  childProcess.stdout.pipe(process.stdout);

  childProcess.stderr.on('data', (data) => {
    stdout += data + '';
  });

  childProcess.stdout.on('data', (data) => {
    stdout += data + '';
  });

  childProcess.on('error', (error) => {
    done(error);
  });

  childProcess.on('close', (code) => {
    let dartErrorMatch = matchError(stdout);
    if (dartErrorMatch) {
      let error = new Error('UnExpected Flutter Assert Failed.');
      done(error);
      return;
    }

    if (code === 0) {
      done();
    } else {
      // TODO: collect error message from stdout.
      const err = new Error('Some error occurred, please check log.');
      done(err);
    }
  });
});

task('unit-test', (done) => {
  const childProcess = spawn('flutter', ['test', '--coverage'], {
    stdio: 'pipe',
    cwd: paths.kraken
  });

  let stdout = '';

  childProcess.stderr.pipe(process.stderr);
  childProcess.stdout.pipe(process.stdout);

  childProcess.stderr.on('data', (data) => {
    stdout += data + '';
  });

  childProcess.stdout.on('data', (data) => {
    stdout += data + '';
  });

  childProcess.on('error', (error) => {
    done(error);
  });

  childProcess.on('close', (code) => {
    let dartErrorMatch = matchError(stdout);
    if (dartErrorMatch) {
      let error = new Error('UnExpected Flutter Assert Failed.');
      done(error);
      return;
    }

    if (code === 0) {
      done();
    } else {
      done(new Error('Some error occurred, please check log.'));
    }
  });
});

task('unit-test-coverage-reporter', (done) => {
  const childProcess = spawn('npm', ['run', 'test:unit:report'], {
    stdio: 'inherit',
    cwd: KRAKEN_ROOT,
  });
  childProcess.on('exit', () => {
    done();
  });
});

task('sdk-clean', (done) => {
  execSync(`rm -rf ${paths.sdk}/build`, { stdio: 'inherit' });
  done();
});

task(`build-ios-kraken-lib`, (done) => {
  const buildType = (buildMode == 'Release' || buildMode === 'RelWithDebInfo') ? 'RelWithDebInfo' : 'Debug';

  // generate build scripts for simulator
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
    -DPLATFORM=SIMULATOR64 \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-x64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      KRAKEN_JS_ENGINE: program.jsEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/x86_64')
    }
  });

  // build for simulator
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-x64 --target kraken kraken_static -- -j 12`, {
    stdio: 'inherit'
  });

  // geneate builds scripts for ARMV7S
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
    -DPLATFORM=OS \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-arm -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      KRAKEN_JS_ENGINE: program.jsEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/arm')
    }
  });

  // build for ARMV7S
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-arm --target kraken kraken_static -- -j 12`, {
    stdio: 'inherit'
  });

  // geneate builds scripts for ARM64
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
     -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
     -DPLATFORM=OS64 \
     ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
     -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-arm64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      KRAKEN_JS_ENGINE: program.jsEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/arm64')
    }
  });

  // build for ARMV64
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-arm64 --target kraken kraken_static -- -j 12`, {
    stdio: 'inherit'
  });

  const armDynamicSDKPath = path.join(paths.bridge, 'build/ios/lib/arm/kraken_bridge.framework');
  const arm64DynamicSDKPath = path.join(paths.bridge, 'build/ios/lib/arm64/kraken_bridge.framework');
  const x64DynamicSDKPath = path.join(paths.bridge, 'build/ios/lib/x86_64/kraken_bridge.framework');

  const targetDynamicSDKPath = `${paths.bridge}/build/ios/framework`;
  const frameworkPath = `${targetDynamicSDKPath}/kraken_bridge.xcframework`;
  mkdirp.sync(targetDynamicSDKPath);

  // merge armv7 into armv8
  execSync(`lipo -create ${armDynamicSDKPath}/kraken_bridge ${arm64DynamicSDKPath}/kraken_bridge -output ${arm64DynamicSDKPath}/kraken_bridge`, {
    stdio: 'inherit'
  });

  if (buildMode === 'RelWithDebInfo') {
    // Create dSYM for x86_64
    execSync(`dsymutil ${x64DynamicSDKPath}/kraken_bridge`, { stdio: 'inherit' });

    // Create dSYM for arm64
    execSync(`dsymutil ${arm64DynamicSDKPath}/kraken_bridge`, { stdio: 'inherit' });
    execSync(`xcodebuild -create-xcframework \
      -framework ${x64DynamicSDKPath} -debug-symbols ${x64DynamicSDKPath}/kraken_bridge.dSYM \
      -framework ${arm64DynamicSDKPath} -debug-symbols ${arm64DynamicSDKPath}/kraken_bridge.dSYM -output ${frameworkPath}`, {
      stdio: 'inherit'
    });

  } else {
    execSync(`xcodebuild -create-xcframework \
      -framework ${x64DynamicSDKPath} \
      -framework ${arm64DynamicSDKPath} -output ${frameworkPath}`, {
      stdio: 'inherit'
    });
  }
  done();
});


task(`build-ios-kraken-lib-profile`, done => {
  let frameworkSource = `${paths.sdk}/build/ios/framework/Release/kraken.framework`;
  let frameworkDest = `${paths.sdk}/build/ios/framework/Profile/kraken.framework`;
  execSync(`cp -r ${frameworkSource} ${frameworkDest}`);
  done();
});

task('build-ios-frameworks', (done) => {
  let cmd = `flutter build ios-framework --cocoapods`;
  execSync(cmd, {
    env: process.env,
    cwd: paths.sdk,
    stdio: 'inherit'
  });

  execSync(`cp -r ${paths.bridge}/build/ios/framework/kraken_bridge.framework ${paths.sdk}/build/ios/framework/Debug`);
  execSync(`cp -r ${paths.bridge}/build/ios/framework/kraken_bridge.dSYM ${paths.sdk}/build/ios/framework/Debug`);
  execSync(`cp -r ${paths.bridge}/build/ios/framework/kraken_bridge.framework ${paths.sdk}/build/ios/framework/Profile`);
  execSync(`cp -r ${paths.bridge}/build/ios/framework/kraken_bridge.framework ${paths.sdk}/build/ios/framework/Release`);

  done();
});

task('build-android-kraken-lib', (done) => {
  let androidHome;

  if (platform == 'win32') {
    androidHome = path.join(process.env.LOCALAPPDATA, 'Android\\Sdk');
  } else {
    androidHome = path.join(process.env.HOME, 'Library/Android/sdk')
  }

  const ndkDir = path.join(androidHome, 'ndk');
  const ndkVersion = '21.4.7075529';

  if (!fs.existsSync(path.join(ndkDir, ndkVersion))) {
    throw new Error('Android NDK version (21.4.7075529) not installed.');
  }

  const archs = ['arm64-v8a', 'armeabi-v7a'];
  const buildType = (buildMode === 'Release' || buildMode == 'Relwithdebinfo') ? 'Relwithdebinfo' : 'Debug';

  const cmakeGeneratorTemplate = platform == 'win32' ? 'Ninja' : 'Unix Makefiles';
  archs.forEach(arch => {
    const soBinaryDirectory = path.join(paths.bridge, `build/android/lib/${arch}`);
    const bridgeCmakeDir = path.join(paths.bridge, 'cmake-build-android-' + arch);
    // generate project
    execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${path.join(androidHome, 'ndk', ndkVersion, '/build/cmake/android.toolchain.cmake')} \
    -DANDROID_NDK=${path.join(androidHome, '/ndk/', ndkVersion)} \
    -DIS_ANDROID=TRUE \
    -DANDROID_ABI="${arch}" \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    -DANDROID_PLATFORM="android-16" \
    -DANDROID_STL=c++_shared \
    -G "${cmakeGeneratorTemplate}" \
    -B ${paths.bridge}/cmake-build-android-${arch} -S ${paths.bridge}`,
      {
        cwd: paths.bridge,
        stdio: 'inherit',
        env: {
          ...process.env,
          KRAKEN_JS_ENGINE: program.jsEngine,
          LIBRARY_OUTPUT_DIR: soBinaryDirectory
        }
      });

    // build
    execSync(`cmake --build ${bridgeCmakeDir} --target kraken -- -j 12`, {
      stdio: 'inherit'
    });
  });

  done();
});

task('android-so-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/android`, { stdio: 'inherit' });
  done();
});

task('build-android-sdk', (done) => {
  execSync(`flutter build aar --build-number ${pkgVersion}`, {
    eng: process.env,
    cwd: path.join(paths.sdk),
    stdio: 'inherit'
  });
  done();
});


task('ios-framework-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/ios`, { stdio: 'inherit' });
  done();
});

task('macos-dylib-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/macos`, { stdio: 'inherit' });
  done();
});

// TODO: support patch windows symbol of quickjs engine.
task('patch-windows-symbol-link-for-android', done => {
  const jniLibsDir = path.join(paths.kraken, 'android/jniLibs');
  const archs = ['arm64-v8a', 'armeabi-v7a'];

  for(let arch of archs) {
    const libPath = path.join(jniLibsDir, arch);
    execSync('rm -f ./*', {
      cwd: libPath,
      shell: winShell,
      stdio: 'inherit'
    });
    fs.copyFileSync(path.join(paths.thirdParty, `JavaScriptCore\\lib\\android\\${arch}\\libjsc.so`), path.join(libPath, 'libjsc.so'));
    fs.copyFileSync(path.join(paths.thirdParty, `JavaScriptCore\\lib\\android\\${arch}\\libc++_shared.so`), path.join(libPath, 'libc++_shared.so'));
    fs.copyFileSync(path.join(paths.bridge, `build/android/lib/${arch}/libkraken_jsc.so`), path.join(libPath, 'libkraken_jsc.so'));
  }

  done();
});

task('android-so-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/android`, { stdio: 'inherit', shell: winShell });
  done();
});

function getDevicesInfo() {
  let output = JSON.parse(execSync('flutter devices --machine', {stdio: 'pipe', encoding: 'utf-8'}));
  let androidDevices = output.filter(device => {
    return device.sdk.indexOf('Android') >= 0;
  });
  if (androidDevices.length == 0) {
    throw new Error('Can not find android benchmark devices.');
  }
  return androidDevices;
}

task('run-benchmark', async (done) => {
  let androidDevices = getDevicesInfo();
  execSync(`flutter run -d ${androidDevices[0].id} --profile`, {stdio: 'inherit', cwd: paths.performanceTests});
  execSync('adb uninstall com.example.performance_tests');
  execSync(`flutter run -d ${androidDevices[0].id} --profile`, {stdio: 'inherit', cwd: paths.performanceTests});
  execSync('adb uninstall com.example.performance_tests');
  execSync(`flutter run -d ${androidDevices[0].id} --profile`, {stdio: 'inherit', cwd: paths.performanceTests});
  execSync('adb uninstall com.example.performance_tests');
  execSync(`flutter run -d ${androidDevices[0].id} --profile`, {stdio: 'inherit', cwd: paths.performanceTests});
  execSync('adb uninstall com.example.performance_tests');
  execSync(`flutter run -d ${androidDevices[0].id} --profile`, {stdio: 'inherit', cwd: paths.performanceTests});
  execSync('adb uninstall com.example.performance_tests');
  execSync(`flutter run -d ${androidDevices[0].id} --profile`, {stdio: 'inherit', cwd: paths.performanceTests});
  execSync('adb uninstall com.example.performance_tests');
  execSync(`flutter run -d ${androidDevices[0].id} --profile`, {stdio: 'inherit', cwd: paths.performanceTests});
  execSync('adb uninstall com.example.performance_tests');
  execSync(`flutter run -d ${androidDevices[0].id} --profile`, {stdio: 'inherit', cwd: paths.performanceTests});
  execSync('adb uninstall com.example.performance_tests');
  execSync(`flutter run -d ${androidDevices[0].id} --profile`, {stdio: 'inherit', cwd: paths.performanceTests});
  execSync('adb uninstall com.example.performance_tests');
  execSync(`flutter run -d ${androidDevices[0].id} --profile`, {stdio: 'inherit', cwd: paths.performanceTests});
  execSync('adb uninstall com.example.performance_tests');
  done();
});
