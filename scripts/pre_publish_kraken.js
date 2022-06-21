const exec = require("child_process").execSync;
const fs = require("fs");
const PATH = require("path");

function symbolicToRealFile(path) {
  let realPath = PATH.join(path, "../", fs.readlinkSync(path));

  if (fs.lstatSync(realPath).isDirectory()) {
    exec(`rm ${path}`);
    exec(`cp -r ${realPath} ${path}`);
  } else {
    let buffer = fs.readFileSync(realPath);
    fs.rmSync(path);
    fs.writeFileSync(path, buffer);
  }
}

const krakenDir = PATH.join(__dirname, "../kraken");

const files = [
  "android/jniLibs/arm64-v8a/libc++_shared.so",
  "android/jniLibs/arm64-v8a/libkraken.so",
  "android/jniLibs/arm64-v8a/libquickjs.so",
  "android/jniLibs/armeabi-v7a/libc++_shared.so",
  "android/jniLibs/armeabi-v7a/libkraken.so",
  "android/jniLibs/armeabi-v7a/libquickjs.so",
  "android/jniLibs/x86/libc++_shared.so",
  "android/jniLibs/x86/libkraken.so",
  "android/jniLibs/x86/libquickjs.so",
  "ios/kraken_bridge.xcframework",
  "ios/quickjs.xcframework",
  "linux/libkraken.so",
  "linux/libquickjs.so",
  "macos/libkraken.dylib",
  "macos/libquickjs.dylib",
];

for (let file of files) {
  symbolicToRealFile(PATH.join(krakenDir, file));
}

