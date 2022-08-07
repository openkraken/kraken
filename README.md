# [WebF](https://openwebf.com/) [![pub package](https://img.shields.io/pub/v/webf.svg)](https://pub.dev/packages/webf)

WebF (Web on the Flutter) is a W3C standard compliant Web rendering engine based on Flutter, it can run web application on Flutter natively.

+ **W3C Standard Compliant:** WebF use HTML/CSS and JavaScript to rendering contents on the flutter. It can achieve 100% consistency with browser rendering.
+ **Front-End Framework Support:** WebF is W3C standard compliant, so it can be used by many Front-End frameworks, including [React](https://reactjs.org/), [Vue](https://vuejs.org/).
+ **Expand your Web with Flutter:** WebF is fully customizable. You can define a customized HTML element with Flutter Widget and used it in your application. Or add a JavaScript API with any Dart library from pub.dev registry.
+ **Web Development Experience:** WebF support inspect your HTML structure, CSS style and Debugging JavaScript with Chrome Developer Tools, just like the web development experience of your browser.
+ **Write Once, Run AnyWhere:** By the power of WebF, You can write your web application and run it on any device flutter supports, and you can still run your apps in Node.js and Web Browser with the same code base.

## Version requirement

| WebF  | Flutter |
| ------------- | ------------- |
| >= 0.12.0 < 0.13.0 | 3.0.5 |

## How to use

**packages.yaml**

```yaml
dependencies:
  webf: <lastest version>
```

**import**

```
import 'package:webf/webf.dart';
```

**Use WebF Widget**


```Dart
@override
Widget build(BuildContext context) {
  final MediaQueryData queryData = MediaQuery.of(context);
  final Size viewportSize = queryData.size;

  return Scaffold(
      body: Center(
    child: Column(
      children: [
        WebF(
          devToolsService: ChromeDevToolsService(), // Enable Chrome DevTools Services
          viewportWidth: viewportSize.width - queryData.padding.horizontal, // Adjust the viewportWidth
          viewportHeight: viewportSize.height - queryData.padding.vertical, // Adjust the viewportHeight
          bundle: WebFBundle.fromUrl('https://andycall.oss-cn-beijing.aliyuncs.com/demo/demo-vue.js'), // The page entry point
        ),
      ],
    ),
  ));
}
```

## How it works

WebF provide a rendering engine which follow the W3C standard like the browser does. It can render HTML/CSS and execute JavaScript. It's built on top of the flutter rendering pipelines and implements its' own layout and paint algorithms.

With WebF, Web Apps and Flutter Apps are sharing the rendering context. It means that you can use Flutter Widgets define your HTML elements and embedded your Web App as a Flutter Widget in your flutter apps.

<img src="https://andycall.oss-accelerate.aliyuncs.com/images/11659542021_.pic.jpg" width="800" style="display: block; margin: 0 auto;" />

## 👏 Contributing [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/openwebf/webf/pulls)

By contributing to WebF, you agree that your contributions will be licensed under its Apache-2.0 License.

Read our [contributing guide](https://github.com/openwebf/webf/blob/main/.github/CONTRIBUTING.md) and let's build a better kraken project together.

Thank you to all the people who already contributed to [OpenWebF](https://github.com/openwebf) and [OpenKraken](https://github.com/openkraken)!

Copyright (c) 2022-present, The OpenWebF authors.

