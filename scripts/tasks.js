/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

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
const uploader = require('./utils/uploader');

program
.option('--static-quickjs', 'Build quickjs as static library and bundled into webf library.', false)
.parse(process.argv);

const SUPPORTED_JS_ENGINES = ['jsc', 'quickjs'];
const targetJSEngine = process.env.WEBF_JS_ENGINE || 'quickjs';

if (SUPPORTED_JS_ENGINES.indexOf(targetJSEngine) < 0) {
  throw new Error('Unsupported js engine:' + targetJSEngine);
}

const WEBF_ROOT = join(__dirname, '..');
const TARGET_PATH = join(WEBF_ROOT, 'targets');
const platform = os.platform();
const buildMode = process.env.WEBF_BUILD || 'Debug';
const paths = {
  targets: resolveWebF('targets'),
  scripts: resolveWebF('scripts'),
  example: resolveWebF('webf/example'),
  webf: resolveWebF('webf'),
  bridge: resolveWebF('bridge'),
  polyfill: resolveWebF('bridge/polyfill'),
  thirdParty: resolveWebF('third_party'),
  tests: resolveWebF('integration_tests'),
  sdk: resolveWebF('sdk'),
  templates: resolveWebF('scripts/templates'),
  performanceTests: resolveWebF('performance_tests')
};

const pkgVersion = readFileSync(path.join(paths.webf, 'pubspec.yaml'), 'utf-8').match(/version: (.*)/)[1].trim();
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

function resolveWebF(submodule) {
  return resolve(WEBF_ROOT, submodule);
}

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

task('build-darwin-webf-lib', done => {
  let externCmakeArgs = [];
  let buildType = 'Debug';
  if (process.env.WEBF_BUILD === 'Release') {
    buildType = 'RelWithDebInfo';
  }

  if (isProfile) {
    externCmakeArgs.push('-DENABLE_PROFILE=TRUE');
  }

  if (process.env.ENABLE_ASAN === 'true') {
    externCmakeArgs.push('-DENABLE_ASAN=true');
  }

  // Bundle quickjs into webf.
  if (program.staticQuickjs) {
    externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  }

  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} -DENABLE_TEST=true ${externCmakeArgs.join(' ')} \
    -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-macos-x86_64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/macos/lib/x86_64')
    }
  });

  let webfTargets = ['webf'];
  if (targetJSEngine === 'quickjs') {
    webfTargets.push('webf_unit_test');
  }
  if (buildMode === 'Debug') {
    webfTargets.push('webf_test');
  }

  execSync(`cmake --build ${paths.bridge}/cmake-build-macos-x86_64 --target ${webfTargets.join(' ')} -- -j 6`, {
    stdio: 'inherit'
  });

  const binaryPath = path.join(paths.bridge, `build/macos/lib/x86_64/libwebf.dylib`);

  if (buildMode == 'Release' || buildMode == 'RelWithDebInfo') {
    execSync(`dsymutil ${binaryPath}`, { stdio: 'inherit' });
    execSync(`strip -S -X -x ${binaryPath}`, { stdio: 'inherit' });
  }

  done();
});

task('run-bridge-unit-test', done => {
  execSync(`${path.join(paths.bridge, 'build/macos/lib/x86_64/webf_unit_test')}`, {stdio: 'inherit'});
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
      WEBF_JS_ENGINE: targetJSEngine
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

task('plugin-test', (done) => {
  const childProcess = spawn('npm', ['run', 'plugin_test'], {
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
    cwd: paths.webf
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
    cwd: WEBF_ROOT,
  });
  childProcess.on('exit', () => {
    done();
  });
});

task('sdk-clean', (done) => {
  execSync(`rm -rf ${paths.sdk}/build`, { stdio: 'inherit' });
  done();
});

function insertStringSlice(code, position, slice) {
  let leftHalf = code.substring(0, position);
  let rightHalf = code.substring(position);

  return leftHalf + slice + rightHalf;
}

function patchiOSFrameworkPList(frameworkPath) {
  const pListPath = path.join(frameworkPath, 'Info.plist');
  let pListString = fs.readFileSync(pListPath, {encoding: 'utf-8'});
  let versionIndex = pListString.indexOf('CFBundleVersion');
  if (versionIndex != -1) {
    let versionStringLast = pListString.indexOf('</string>', versionIndex) + '</string>'.length;

    pListString = insertStringSlice(pListString, versionStringLast, `
        <key>MinimumOSVersion</key>
        <string>9.0</string>`);
    fs.writeFileSync(pListPath, pListString);
  }
}

task(`build-ios-webf-lib`, (done) => {
  const buildType = (buildMode == 'Release' || buildMode === 'RelWithDebInfo')  ? 'RelWithDebInfo' : 'Debug';
  let externCmakeArgs = [];

  if (process.env.ENABLE_ASAN === 'true') {
    externCmakeArgs.push('-DENABLE_ASAN=true');
  }

  // Bundle quickjs into webf.
  if (program.staticQuickjs) {
    externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  }

  // generate build scripts for simulator
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
    -DPLATFORM=SIMULATOR64 \
    -DDEPLOYMENT_TARGET=9.0 \
    -DIS_IOS=TRUE \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    ${externCmakeArgs.join(' ')} \
    -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-x64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/x86_64')
    }
  });

  // build for simulator
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-x64 --target webf webf_static -- -j 12`, {
    stdio: 'inherit'
  });

  // Generate builds scripts for ARMv7s, ARMv7
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
    -DPLATFORM=OS \
    -DIS_IOS=TRUE \
    -DARCHS="armv7;armv7s" \
    -DDEPLOYMENT_TARGET=9.0 \
    ${externCmakeArgs.join(' ')} \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-arm -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/arm')
    }
  });

  // Build for ARMv7, ARMv7s
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-arm --target webf webf_static -- -j 12`, {
    stdio: 'inherit'
  });

  // Generate builds scripts for ARMv7s, ARMv7
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
    -DPLATFORM=OS64 \
    -DDEPLOYMENT_TARGET=9.0 \
    -DIS_IOS=TRUE \
    ${externCmakeArgs.join(' ')} \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-arm64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      WEBF_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/arm64')
    }
  });

  // Build for ARM64
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-arm64 --target webf webf_static -- -j 12`, {
    stdio: 'inherit'
  });

  const targetSourceFrameworks = ['webf_bridge'];

  // If quickjs is not static, there will be another framework called quickjs.framework.
  if (!program.staticQuickjs) {
    targetSourceFrameworks.push('quickjs');
  }

  targetSourceFrameworks.forEach(target => {
    const armDynamicSDKPath = path.join(paths.bridge, `build/ios/lib/arm/${target}.framework`);
    const arm64DynamicSDKPath = path.join(paths.bridge, `build/ios/lib/arm64/${target}.framework`);
    const x64DynamicSDKPath = path.join(paths.bridge, `build/ios/lib/x86_64/${target}.framework`);

    // Create flat frameworks with multiple archs.
    execSync(`lipo -create ${armDynamicSDKPath}/${target} ${arm64DynamicSDKPath}/${target} -output ${armDynamicSDKPath}/${target}`, {
      stdio: 'inherit'
    });

    // CMake generated iOS frameworks does not contains <MinimumOSVersion> key in Info.plist.
    patchiOSFrameworkPList(x64DynamicSDKPath);
    patchiOSFrameworkPList(armDynamicSDKPath);

    const targetDynamicSDKPath = `${paths.bridge}/build/ios/framework`;
    const frameworkPath = `${targetDynamicSDKPath}/${target}.xcframework`;
    mkdirp.sync(targetDynamicSDKPath);

    // dSYM file are located at /path/to/webf/build/ios/lib/${arch}/target.dSYM.
    // Create dSYM for x86_64.
    execSync(`dsymutil ${x64DynamicSDKPath}/${target} --out ${x64DynamicSDKPath}/../${target}.dSYM`, { stdio: 'inherit' });
    // Create dSYM for arm64,armv7.
    execSync(`dsymutil ${armDynamicSDKPath}/${target} --out ${armDynamicSDKPath}/../${target}.dSYM`, { stdio: 'inherit' });

    // Generated xcframework at located at /path/to/webf/build/ios/framework/${target}.xcframework.
    // Generate xcframework with dSYM.
    if (buildMode === 'RelWithDebInfo') {
      execSync(`xcodebuild -create-xcframework \
        -framework ${x64DynamicSDKPath} -debug-symbols ${x64DynamicSDKPath}/../${target}.dSYM \
        -framework ${armDynamicSDKPath} -debug-symbols ${armDynamicSDKPath}/../${target}.dSYM -output ${frameworkPath}`, {
        stdio: 'inherit'
      });
    } else {
      execSync(`xcodebuild -create-xcframework \
        -framework ${x64DynamicSDKPath} \
        -framework ${armDynamicSDKPath} -output ${frameworkPath}`, {
        stdio: 'inherit'
      });
    }
  });
  done();
});

task('build-ios-frameworks', (done) => {
  let cmd = `flutter build ios-framework --cocoapods`;
  execSync(cmd, {
    env: process.env,
    cwd: paths.sdk,
    stdio: 'inherit'
  });

  execSync(`cp -r ${paths.bridge}/build/ios/framework/webf_bridge.xcframework ${paths.sdk}/build/ios/framework/Debug`);
  execSync(`cp -r ${paths.bridge}/build/ios/framework/webf_bridge.xcframework ${paths.sdk}/build/ios/framework/Profile`);
  execSync(`cp -r ${paths.bridge}/build/ios/framework/webf_bridge.xcframework ${paths.sdk}/build/ios/framework/Release`);

  done();
});

task('build-linux-webf-lib', (done) => {
  const buildType = buildMode == 'Release' ? 'Release' : 'Relwithdebinfo';
  const cmakeGeneratorTemplate = platform == 'win32' ? 'Ninja' : 'Unix Makefiles';

  const soBinaryDirectory = path.join(paths.bridge, `build/linux/lib/`);
  const bridgeCmakeDir = path.join(paths.bridge, 'cmake-build-linux');
  // generate project
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
  ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
  -G "${cmakeGeneratorTemplate}" \
  -B ${paths.bridge}/cmake-build-linux -S ${paths.bridge}`,
    {
      cwd: paths.bridge,
      stdio: 'inherit',
      env: {
        ...process.env,
        WEBF_JS_ENGINE: targetJSEngine,
        LIBRARY_OUTPUT_DIR: soBinaryDirectory
      }
    });

  // build
  execSync(`cmake --build ${bridgeCmakeDir} --target webf -- -j 12`, {
    stdio: 'inherit'
  });

  const libwebfPath = path.join(paths.bridge, 'build/linux/lib/libwebf.so');
  // Patch libwebf.so's runtime path.
  execSync(`chrpath --replace \\$ORIGIN ${libwebfPath}`, { stdio: 'inherit' });

  done();
});

task('build-android-webf-lib', (done) => {
  let androidHome;

  let ndkDir = '';

  // If ANDROID_NDK_HOME env defined, use it.
  if (process.env.ANDROID_NDK_HOME) {
    ndkDir = process.env.ANDROID_NDK_HOME;
  } else {
    if (platform == 'win32') {
      androidHome = path.join(process.env.LOCALAPPDATA, 'Android\\Sdk');
    } else {
      androidHome = path.join(process.env.HOME, 'Library/Android/sdk')
    }
    const ndkVersion = '23.2.8568313';
    ndkDir = path.join(androidHome, 'ndk', ndkVersion);

    if (!fs.existsSync(ndkDir)) {
      throw new Error('Android NDK version (23.2.8568313) not installed.');
    }
  }

  const archs = ['arm64-v8a', 'armeabi-v7a', 'x86'];
  const toolChainMap = {
    'arm64-v8a': 'aarch64-linux-android',
    'armeabi-v7a': 'arm-linux-androideabi',
    'x86': 'i686-linux-android'
  };
  const buildType = (buildMode === 'Release' || buildMode == 'Relwithdebinfo') ? 'Relwithdebinfo' : 'Debug';
  let externCmakeArgs = [];

  if (process.env.ENABLE_ASAN === 'true') {
    externCmakeArgs.push('-DENABLE_ASAN=true');
  }

  // Bundle quickjs into webf.
  if (program.staticQuickjs) {
    externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  }

  const soFileNames = [
    'libwebf',
    'libc++_shared'
  ];

  // If quickjs is not static, there will be another so called libquickjs.so.
  if (!program.staticQuickjs) {
    soFileNames.push('libquickjs');
  }

  const cmakeGeneratorTemplate = platform == 'win32' ? 'Ninja' : 'Unix Makefiles';
  archs.forEach(arch => {
    const soBinaryDirectory = path.join(paths.bridge, `build/android/lib/${arch}`);
    const bridgeCmakeDir = path.join(paths.bridge, 'cmake-build-android-' + arch);
    // generate project
    execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${path.join(ndkDir, '/build/cmake/android.toolchain.cmake')} \
    -DANDROID_NDK=${ndkDir} \
    -DIS_ANDROID=TRUE \
    -DANDROID_ABI="${arch}" \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    ${externCmakeArgs.join(' ')} \
    -DANDROID_PLATFORM="android-18" \
    -DANDROID_STL=c++_shared \
    -G "${cmakeGeneratorTemplate}" \
    -B ${paths.bridge}/cmake-build-android-${arch} -S ${paths.bridge}`,
      {
        cwd: paths.bridge,
        stdio: 'inherit',
        env: {
          ...process.env,
          WEBF_JS_ENGINE: targetJSEngine,
          LIBRARY_OUTPUT_DIR: soBinaryDirectory
        }
      });

    // build
    execSync(`cmake --build ${bridgeCmakeDir} --target webf -- -j 12`, {
      stdio: 'inherit'
    });

    // Copy libc++_shared.so to dist from NDK.
    const libcppSharedPath = path.join(ndkDir, `./toolchains/llvm/prebuilt/${os.platform()}-x86_64/sysroot/usr/lib/${toolChainMap[arch]}/libc++_shared.so`);
    execSync(`cp ${libcppSharedPath} ${soBinaryDirectory}`);

    // Strip release binary in release mode.
    if (buildMode === 'Release' || buildMode === 'RelWithDebInfo') {
      const strip = path.join(ndkDir, `./toolchains/llvm/prebuilt/${os.platform()}-x86_64/bin/llvm-strip`);
      const objcopy = path.join(ndkDir, `./toolchains/llvm/prebuilt/${os.platform()}-x86_64/bin/llvm-objcopy`);

      for (let soFileName of soFileNames) {
        const soBinaryFile = path.join(soBinaryDirectory, soFileName + '.so');
        execSync(`${objcopy} --only-keep-debug "${soBinaryFile}" "${soBinaryDirectory}/${soFileName}.debug"`);
        execSync(`${strip} --strip-debug --strip-unneeded "${soBinaryFile}"`)
      }
    }
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

task('android-so-clean', (done) => {
  execSync(`rm -rf ${paths.bridge}/build/android`, { stdio: 'inherit', shell: winShell });
  done();
});

task('build-benchmark-app', async (done) => {
  execSync('npm install', { cwd: path.join(paths.performanceTests, '/benchmark') });
  const result = spawnSync('npm', ['run', 'build'], {
    cwd: path.join(paths.performanceTests, '/benchmark')
  });

  if (result.status !== 0) {
    return done(result.status);
  }

  done();
})
