### 介绍

kraken工具链，包括:

* JSDebugger
* Console
* Memory Inspector

特点:

* 基于chrome debugging protocol
* 实现debugger和runtime domain
* 通信使用websocket+jsonrpc
* 不仅可以用在kraken项目，也可以用在任何使用js引擎的项目

### 接入

* step1: 编译devtools动态/静态库
* step2: 初始化

```
auto devtools_ = kraken::Debugger::FrontDoor::newInstance(global,nullptr,"127.0.0.1");
devtools_->setup();
```

* step3: 销毁

```
devtools_->terminate();
```

### owner

@楚奕
