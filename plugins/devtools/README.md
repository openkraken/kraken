# Kraken Devtools [![pub package](https://img.shields.io/pub/v/kraken_devtools.svg)](https://pub.dev/packages/kraken_devtools)

A kraken plugin which starting a service to provide Chrome DevTools support.

## Install

First, add `kraken_devtools` as a dependency in your pubspec.yaml file.

```dart
import 'package:kraken_devtools/kraken_devtools.dart';

Kraken kraken = Kraken(
  // ...
  devToolsService: ChromeDevToolsService(),
);
```

## How to use

When kraken app started, there will be logs printed in terminal like below.
```
flutter: Kraken DevTool listening at ws://127.0.0.1:9222
flutter: Open Chrome/Edge and paste following url to your navigator:
flutter:     devtools://devtools/bundled/inspector.html?ws=127.0.0.1:9222
```

Open Chrome/Edge and paste url started with 'devtools://' to your navigator.

## Features

**DOM inspector**

![image](https://user-images.githubusercontent.com/4409743/116355211-1dfbca00-a82c-11eb-8904-5839c14f5393.png)

**Console Panel**

![image](https://user-images.githubusercontent.com/4409743/116355389-5dc2b180-a82c-11eb-98e5-4bd9e7456904.png)

**JavaScript Debugger**

> Not supported in quickjs engine now.

![image](https://user-images.githubusercontent.com/4409743/116355613-aaa68800-a82c-11eb-93f4-b2fcbcbbd0ba.png)
