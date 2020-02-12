# Kraken test

渲染容器测试框架

## 测试原理

1. 使用 flutter integration test 注入已经运行的 app.dart
2. 每个 fixtures 下的 js 文件都是一个测试用例
3. 用例串行执行
4. app_test.dart 会驱动 app.dart 执行测试，并截图进行像素对比, 若 snapshots 中对应图片不存在会直接保存

## Usage

- 执行测试：npm run test:flutter
  - 需要注意的是，kraken 需要传入 localEngine 的类型和地址, 请替换成本地的 eg:
  `npm run test:flutter  --  --local-engine=host_debug --local-engine-src-path=/Users/zhuoling/workspace/kraken_workspace/engine/src`
