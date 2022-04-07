# Kraken Contributing Guide

0. Prerequisites
    * [Node.js](https://nodejs.org/) v12.0 or later
    * [Flutter](https://flutter.dev/docs/get-started/install) version in the `kraken/pubspec.yaml`
    * [CMake](https://cmake.org/) v3.2.0 or later
    * [Xcode](https://developer.apple.com/xcode/) (10.12) or later (Running on macOS or iOS)
    * [Android NDK](https://developer.android.com/studio/projects/install-ndk) version `21.4.7075529` (Running on Android)

1. Install

    ```shell
    $ npm install
    ```

2. Building bridge

    Building bridge for all supported platform (macOS, linux, iOS, Android)

    ```shell
    $ npm run build:bridge:all
    ```

    Building bridge for one platform

    **macOS**

    ```shell
    $ npm run build:bridge:macos
    ```

    **linux**

    ```shell
    $ npm run build:bridge:linux
    ```

    **iOS**

    ```shell
    $ npm run build:bridge:ios
    ```

    **Android**

    > For Windows users, make sure that running this command under MINGW64 environment(eg. Git Bash).

    ```shell
    $ npm run build:bridge:android
    ```

3. Start example
    ```shell
    $ cd kraken/example
    $ flutter run
    ```

4. Test (Unit Test and Integration Test)
    ```shell
    $ npm test
    ```

