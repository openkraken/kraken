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
.option('--static-quickjs', 'Build quickjs as static library and bundled into kraken library.', false)
.parse(process.argv);

const SUPPORTED_JS_ENGINES = ['jsc', 'quickjs'];
const targetJSEngine = process.env.KRAKEN_JS_ENGINE || 'quickjs';

if (SUPPORTED_JS_ENGINES.indexOf(targetJSEngine) < 0) {
  throw new Error('Unsupported js engine:' + targetJSEngine);
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
  let externCmakeArgs = [];
  let buildType = 'Debug';
  if (process.env.KRAKEN_BUILD === 'Release') {
    buildType = 'RelWithDebInfo';
  }

  if (isProfile) {
    externCmakeArgs.push('-DENABLE_PROFILE=TRUE');
  }

  if (process.env.ENABLE_ASAN === 'true') {
    externCmakeArgs.push('-DENABLE_ASAN=true');
  }

  // Bundle quickjs into kraken.
  if (program.staticQuickjs) {
    externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  }

  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} -DENABLE_TEST=true ${externCmakeArgs.join(' ')} \
    -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-macos-x86_64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      KRAKEN_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/macos/lib/x86_64')
    }
  });

  let krakenTargets = ['kraken'];
  if (targetJSEngine === 'quickjs') {
    krakenTargets.push('kraken_unit_test');
  }
  if (buildMode === 'Debug') {
    krakenTargets.push('kraken_test');
  }

  execSync(`cmake --build ${paths.bridge}/cmake-build-macos-x86_64 --target ${krakenTargets.join(' ')} -- -j 6`, {
    stdio: 'inherit'
  });

  const binaryPath = path.join(paths.bridge, `build/macos/lib/x86_64/libkraken.dylib`);

  if (targetJSEngine === 'jsc') {
    execSync(`install_name_tool -change /System/Library/Frameworks/JavaScriptCore.framework/Versions/A/JavaScriptCore @rpath/JavaScriptCore.framework/Versions/A/JavaScriptCore ${binaryPath}`);
  }
  if (buildMode == 'Release' || buildMode == 'RelWithDebInfo') {
    execSync(`dsymutil ${binaryPath}`, { stdio: 'inherit' });
    execSync(`strip -S -X -x ${binaryPath}`, { stdio: 'inherit' });
  }

  done();
});

task('run-bridge-unit-test', done => {
  execSync(`${path.join(paths.bridge, 'build/macos/lib/x86_64/kraken_unit_test')}`, {stdio: 'inherit'});
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
      KRAKEN_JS_ENGINE: targetJSEngine
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

task(`build-ios-kraken-lib`, (done) => {
  const buildType = (buildMode == 'Release' || buildMode === 'RelWithDebInfo')  ? 'RelWithDebInfo' : 'Debug';
  let externCmakeArgs = [];

  if (process.env.ENABLE_ASAN === 'true') {
    externCmakeArgs.push('-DENABLE_ASAN=true');
  }

  // Bundle quickjs into kraken.
  if (program.staticQuickjs) {
    externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  }

  // generate build scripts for simulator
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
    -DPLATFORM=SIMULATOR64 \
    -DDEPLOYMENT_TARGET=9.0 \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    ${externCmakeArgs.join(' ')} \
    -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-x64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      KRAKEN_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/x86_64')
    }
  });

  // build for simulator
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-x64 --target kraken kraken_static -- -j 12`, {
    stdio: 'inherit'
  });

  // Generate builds scripts for ARMv7s, ARMv7
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
    -DPLATFORM=OS \
    -DARCHS="armv7;armv7s" \
    -DDEPLOYMENT_TARGET=9.0 \
    ${externCmakeArgs.join(' ')} \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-arm -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      KRAKEN_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/arm')
    }
  });

  // Build for ARMv7, ARMv7s
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-arm --target kraken kraken_static -- -j 12`, {
    stdio: 'inherit'
  });

  // Generate builds scripts for ARMv7s, ARMv7
  execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    -DCMAKE_TOOLCHAIN_FILE=${paths.bridge}/cmake/ios.toolchain.cmake \
    -DPLATFORM=OS64 \
    -DDEPLOYMENT_TARGET=9.0 \
    ${externCmakeArgs.join(' ')} \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    -DENABLE_BITCODE=FALSE -G "Unix Makefiles" -B ${paths.bridge}/cmake-build-ios-arm64 -S ${paths.bridge}`, {
    cwd: paths.bridge,
    stdio: 'inherit',
    env: {
      ...process.env,
      KRAKEN_JS_ENGINE: targetJSEngine,
      LIBRARY_OUTPUT_DIR: path.join(paths.bridge, 'build/ios/lib/arm64')
    }
  });

  // Build for ARM64
  execSync(`cmake --build ${paths.bridge}/cmake-build-ios-arm64 --target kraken kraken_static -- -j 12`, {
    stdio: 'inherit'
  });

  const targetSourceFrameworks = ['kraken_bridge'];

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

    // dSYM file are located at /path/to/kraken/build/ios/lib/${arch}/target.dSYM.
    // Create dSYM for x86_64.
    execSync(`dsymutil ${x64DynamicSDKPath}/${target} --out ${x64DynamicSDKPath}/../${target}.dSYM`, { stdio: 'inherit' });
    // Create dSYM for arm64,armv7.
    execSync(`dsymutil ${armDynamicSDKPath}/${target} --out ${armDynamicSDKPath}/../${target}.dSYM`, { stdio: 'inherit' });

    // Generated xcframework at located at /path/to/kraken/build/ios/framework/${target}.xcframework.
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

  execSync(`cp -r ${paths.bridge}/build/ios/framework/kraken_bridge.xcframework ${paths.sdk}/build/ios/framework/Debug`);
  execSync(`cp -r ${paths.bridge}/build/ios/framework/kraken_bridge.xcframework ${paths.sdk}/build/ios/framework/Profile`);
  execSync(`cp -r ${paths.bridge}/build/ios/framework/kraken_bridge.xcframework ${paths.sdk}/build/ios/framework/Release`);

  done();
});

task('build-linux-arm64-kraken-lib', (done) => {

  const archs = ['arm64'];
  const buildType = buildMode == 'Release' ? 'Release' : 'Relwithdebinfo';
  const cmakeGeneratorTemplate = platform == 'win32' ? 'Ninja' : 'Unix Makefiles';
  archs.forEach(arch => {
    const soBinaryDirectory = path.join(paths.bridge, `build/linux/lib/${arch}`);
    const bridgeCmakeDir = path.join(paths.bridge, 'cmake-build-linux-' + arch);
    // generate project
    execSync(`cmake -DCMAKE_BUILD_TYPE=${buildType} \
    ${isProfile ? '-DENABLE_PROFILE=TRUE \\' : '\\'}
    -G "${cmakeGeneratorTemplate}" \
    -B ${paths.bridge}/cmake-build-linux-${arch} -S ${paths.bridge}`,
      {
        cwd: paths.bridge,
        stdio: 'inherit',
        env: {
          ...process.env,
          KRAKEN_JS_ENGINE: targetJSEngine,
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
  const toolChainMap = {
    'arm64-v8a': 'aarch64-linux-android',
    'armeabi-v7a': 'arm-linux-androideabi'
  };
  const buildType = (buildMode === 'Release' || buildMode == 'Relwithdebinfo') ? 'Relwithdebinfo' : 'Debug';
  let externCmakeArgs = [];

  if (process.env.ENABLE_ASAN === 'true') {
    externCmakeArgs.push('-DENABLE_ASAN=true');
  }

  // Bundle quickjs into kraken.
  if (program.staticQuickjs) {
    externCmakeArgs.push('-DSTATIC_QUICKJS=true');
  }

  const soFileNames = [
    'libkraken',
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
    const ndkDir = path.join(androidHome, 'ndk', ndkVersion);
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
          KRAKEN_JS_ENGINE: targetJSEngine,
          LIBRARY_OUTPUT_DIR: soBinaryDirectory
        }
      });

    // build
    execSync(`cmake --build ${bridgeCmakeDir} --target kraken -- -j 12`, {
      stdio: 'inherit'
    });

    // Copy libc++_shared.so to dist from NDK.
    const libcppSharedPath = path.join(ndkDir, `./toolchains/llvm/prebuilt/${os.platform()}-x86_64/sysroot/usr/lib/${toolChainMap[arch]}/libc++_shared.so`);
    execSync(`cp ${libcppSharedPath} ${soBinaryDirectory}`);

    // Strip release binary in release mode.
    if (buildMode === 'Release' || buildMode === 'RelWithDebInfo') {
      const strip = path.join(ndkDir, `./toolchains/llvm/prebuilt/${os.platform()}-x86_64/${toolChainMap[arch]}/bin/strip`);
      const objcopy = path.join(ndkDir, `./toolchains/llvm/prebuilt/${os.platform()}-x86_64/${toolChainMap[arch]}/bin/objcopy`);

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
