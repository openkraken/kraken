## 0.8.4

**Break Changes**

+ Navigator.vibrate API no long support as default. https://github.com/openkraken/kraken/pull/655
+ Rename `kraken.setMethodCallHandler` to `kraken.addMethodCallHandler`. https://github.com/openkraken/kraken/pull/658
+ `gestureClient` API migrated to `GestureListener` API. https://github.com/openkraken/kraken/pull/716


**Features**

+ Support documentFragment. https://github.com/openkraken/kraken/pull/641
+ Add default 1em margin for `<p>` https://github.com/openkraken/kraken/pull/648
+ Support document.querySelector and document.querySelectorAll. https://github.com/openkraken/kraken/pull/672
+ Improve canvas performance when drawing pictures. https://github.com/openkraken/kraken/pull/679
+ Use xcframework for iOS release. https://github.com/openkraken/kraken/pull/698
+ Support vue-router with History API. https://github.com/openkraken/kraken/pull/711
+ Support `<template />` and element.innerHTML API. https://github.com/openkraken/kraken/pull/713
+ Support offline http cache. https://github.com/openkraken/kraken/pull/723


**Bug Fixed**

+ Fix webpack hot reload. https://github.com/openkraken/kraken/issues/642
+ Fix hit test with detached child render object. https://github.com/openkraken/kraken/pull/651
+ Fix silver conflict with overflow-y. https://github.com/openkraken/kraken/pull/662
+ Fix child of flex item with flex-grow not stretch. https://github.com/openkraken/kraken/pull/665
+ Fix auto margin in flexbox. https://github.com/openkraken/kraken/pull/667
+ Fix positioned element size wrong when no width/height is set. https://github.com/openkraken/kraken/pull/671
+ Fix scroll not working when overflowY is set to auto/scroll and overflowX not set. https://github.com/openkraken/kraken/pull/681
+ Fix multi frame image can replay when loading from caches.  https://github.com/openkraken/kraken/pull/685
+ Fix main axis auto size not including margin. https://github.com/openkraken/kraken/pull/702

## 0.8.3+3

**Bug Fixed**

+ Fix error when reading local path. https://github.com/openkraken/kraken/pull/635

## 0.8.3+2

**Bug Fixed**

+ Fix fetch request lost HTTP headers. https://github.com/openkraken/kraken/pull/633

## 0.8.3+1

**Bug Fixed**

+ Fix ios build. https://github.com/openkraken/kraken/pull/629

## 0.8.3

**Bug Fixed**

+ Fix crash caused by context has been released. https://github.com/openkraken/kraken/pull/605
+ Fix window.open() not working when bundleURL not exist. https://github.com/openkraken/kraken/pull/612
+ Fix location.href is empty when set onLoadError handler. https://github.com/openkraken/kraken/pull/613
+ Fix http cache should not intercept multi times. https://github.com/openkraken/kraken/pull/619
+ Fix input value when set to null. https://github.com/openkraken/kraken/pull/623
+ Fix input change event not trigger when blur. https://github.com/openkraken/kraken/pull/626
+ Fix keyboard not shown when keyboard dismissed and input gets focused again. https://github.com/openkraken/kraken/pull/627

**Features**

+ Support window.onerror and global error event. https://github.com/openkraken/kraken/pull/601
+ Add HTML Head's tags, like `<head>`, `<link>`, `<style>`. https://github.com/openkraken/kraken/pull/603
+ Support customize `User-Agent` header. https://github.com/openkraken/kraken/pull/604
+ Remove androidx dependence. https://github.com/openkraken/kraken/pull/606
+ Add default margin for h1-h6 elements. https://github.com/openkraken/kraken/pull/607


## 0.8.2+1

**Bug Fixed**

+ Fix kraken widget layout size https://github.com/openkraken/kraken/pull/584
+ Fix input can not focus when hitting enter key https://github.com/openkraken/kraken/pull/595

## 0.8.2

**Features**

+ Support percentage for translate3d translateX and translateY https://github.com/openkraken/kraken/pull/547
+ Add findProxyFromEnvironment methods in HttpOverrides. https://github.com/openkraken/kraken/pull/551/files
+ Treat empty scheme as https protocol. https://github.com/openkraken/kraken/pull/557/files
+ Support length/percentage value for background-size. https://github.com/openkraken/kraken/pull/568
+ Support dbclick event. https://github.com/openkraken/kraken/pull/573


**Bug Fixed**

+ Fix crash when HMR enabled. https://github.com/openkraken/kraken/pull/507
+ Fix parent box height can't auto caculate by scrollable container children. https://github.com/openkraken/kraken/pull/517
+ Fix linear-gradient parse failed when have more than one bracket. https://github.com/openkraken/kraken/pull/518
+ Fix image flex items have no size. https://github.com/openkraken/kraken/pull/520
+ Fix transition throw error. https://github.com/openkraken/kraken/pull/542
+ Fix empty screen in launcher mode. https://github.com/openkraken/kraken/pull/544
+ Fix element instanceof HTMLElement return false https://github.com/openkraken/kraken/pull/546
+ Fix transition animation execution order. https://github.com/openkraken/kraken/pull/559
+ Fix transition of backgroundColor with no default value not working. https://github.com/openkraken/kraken/pull/562
+ Fix opacity 0 not working. https://github.com/openkraken/kraken/pull/565
+ Fix hittest with z-index order. https://github.com/openkraken/kraken/pull/572
+ Fix click event not triggerd on input element. https://github.com/openkraken/kraken/pull/575
+ Fix ios bridge build. https://github.com/openkraken/kraken/pull/576


## 0.8.1

**Features**

+ input element not support maxlength property https://github.com/openkraken/kraken/pull/450
+ support em and rem CSS length https://github.com/openkraken/kraken/pull/475


**Bug Fixed**

+ remove same origin policy for xhr https://github.com/openkraken/kraken/pull/463
+ fix error when scroll to top in silver box https://github.com/openkraken/kraken/issues/468
+ fix js contextId allocate order error https://github.com/openkraken/kraken/pull/474 https://github.com/openkraken/kraken/pull/477


## 0.8.0+2

**Features**

+ input element now support inputmode property https://github.com/openkraken/kraken/pull/441

## 0.8.0+1

**Bug Fixed**

+ Fix DOM events can't bind with addEventListener https://github.com/openkraken/kraken/pull/436

## 0.8.0

**Big News**

+ Kraken v0.8.0 now support flutter 2.2.0

**Features**

+ Support dart null safety and all dependencies had upgraded.
+ Lock Android NDK version to 21.4.7075529. https://github.com/openkraken/kraken/pull/394
+ Add length value support in background-position https://github.com/openkraken/kraken/pull/421

**Bug Fixed**

+ Fix error when setting element's eventHandler property to null  https://github.com/openkraken/kraken/pull/426
+ Fix crash when trigger `touchcancel` events https://github.com/openkraken/kraken/pull/424
+ Fix error when reload kraken pages. https://github.com/openkraken/kraken/pull/419
+ Fix element's doesn't show up when setting display: none to display: block. https://github.com/openkraken/kraken/pull/405
+ Fix empty blank screen in Android / iOS physical devices launching with SDK mode. https://github.com/openkraken/kraken/pull/399
+ Fix WebView (created by iframe element) can't scroll. https://github.com/openkraken/kraken/pull/398
+ Fix percentage length doesn't work in flex layout box. https://github.com/openkraken/kraken/pull/397
+ Fix input element's height can't set with CSS height property. https://github.com/openkraken/kraken/pull/395
+ Fix crash when set element.style multiple times in a short of times. https://github.com/openkraken/kraken/pull/391

## 0.7.3+2

**Features**

+ Input element now support type=password options https://github.com/openkraken/kraken/pull/377

**Bug Fixed**

+ Fix event can't bubble to document element https://github.com/openkraken/kraken/pull/380
+ fix: fix bridge crash with getStringProperty on InputElement. https://github.com/openkraken/kraken/pull/386

## 0.7.3+1

* Fix: fix prebuilt binary.
## 0.7.3

**Features**

+ Feat: add network proxy interface in dart widget API https://github.com/openkraken/kraken/pull/292
+ Feat: add AsyncStorage.length method https://github.com/openkraken/kraken/pull/298
+ Feat: improve bridge call performance. https://github.com/openkraken/kraken/pull/328
+ feat: add SVGElement https://github.com/openkraken/kraken/pull/338


**Bug Fixed**
+ Fix input setting value does not take effect before adding the dom tree. https://github.com/openkraken/kraken/pull/297/files
+ Fix: remove unnecessary flushUICommand https://github.com/openkraken/kraken/pull/318
+ Fix: img lazy loading not work https://github.com/openkraken/kraken/pull/319
+ Fix: touchend crash caused by bridge https://github.com/openkraken/kraken/pull/320
+ Fix: fix target of the event agent does not point to the clicked Node https://github.com/openkraken/kraken/pull/322

**Refactor**

+ refactor: position sticky https://github.com/openkraken/kraken/pull/324

## 0.7.2+4

feat: support mouse event https://github.com/openkraken/kraken/pull/220
fix: event bubble not works properly https://github.com/openkraken/kraken/pull/264
fix: return value of Event.stopPropagation() should be undefined https://github.com/openkraken/kraken/pull/284
fix/text node value https://github.com/openkraken/kraken/pull/279
fix: fix kraken.methodChannel.setMethodCallHandler did't get called before kraken.invokeMethod called https://github.com/openkraken/kraken/pull/289

## 0.7.2+3

feat: add willReload and didReload hooks for devTools.

## 0.7.2+2

fix: export getUIThreadId and getGlobalContextRef symbols.

## 0.7.2+1

fix: export getDartMethod() symbols.

## 0.7.2

**Break Changes**

fix: change default font size from 14px to 16px https://github.com/openkraken/kraken/pull/145

**Bug Fixed**
fix: modify customevent to event https://github.com/openkraken/kraken/pull/138
fix: layout performance  https://github.com/openkraken/kraken/pull/155
fix: fix elements created by new operator didn't have ownerDocument. https://github.com/openkraken/kraken/pull/178
fix: flex-basis rule https://github.com/openkraken/kraken/pull/176
fix: transform functions split error when more than one.  https://github.com/openkraken/kraken/pull/196
fix: Fix the crash caused by navigation in dart https://github.com/openkraken/kraken/pull/249
fix update device_info 1.0.0  https://github.com/openkraken/kraken/pull/262

## 0.7.1

**Bug Fixed**

- fix: resize img wainting for img layouted[#86](https://github.com/openkraken/kraken/pull/86)
- fix: fix: encoding snapshots filename to compact with windows. [#69](https://github.com/openkraken/kraken/pull/69)
- fix: fix insertBefore crash when passing none node object. [#70](https://github.com/openkraken/kraken/pull/70)
- fix: windows platform support build target to Android. [#88](https://github.com/openkraken/kraken/pull/88)
- fix: element size not change when widget size change [#90](https://github.com/openkraken/kraken/pull/90)
- fix: fix navigation failed of anchor element. [#95](https://github.com/openkraken/kraken/pull/95)
- fix: 'kraken.methodChannel.setMethodCallHandler' override previous handler [#96](https://github.com/openkraken/kraken/pull/96)
- fix: repaintBoundary convert logic [#111](https://github.com/openkraken/kraken/pull/111)
- fix: element append order wrong with comment node exists [#116](https://github.com/openkraken/kraken/pull/116)
- fix: fix access Node.previousSibling crashed when target node at top of childNodes. [#126](https://github.com/openkraken/kraken/pull/126)
- fix: fix access Element.children crashed when contains non-element nodes in childNodes. [#126](https://github.com/openkraken/kraken/pull/126)
- fix: percentage resolve fail with multiple sibling exists [#144](https://github.com/openkraken/kraken/pull/144)
- fix: default unknow element display change to inline [#133](https://github.com/openkraken/kraken/pull/133)

**Feature**

- feat: support Node.ownerDocument [#107](https://github.com/openkraken/kraken/pull/107)
- feat: support vmin and vmax [#109](https://github.com/openkraken/kraken/pull/109)
- feat: support css none value [#129](https://github.com/openkraken/kraken/pull/129)
- feat: suport Event.initEvent() and Document.createEvent() [#130](https://github.com/openkraken/kraken/pull/131)
- feat: Add block element: h1-h6 main header aside. [#133](https://github.com/openkraken/kraken/pull/133)
- feat: Add inline element: small i code samp... [#133](https://github.com/openkraken/kraken/pull/133)

## 0.7.0

**Bug Fixed**

- fix: zIndex set fail [#45](https://github.com/openkraken/kraken/pull/45)
- fix: border radius percentage [#50](https://github.com/openkraken/kraken/pull/50)
- fix: create text node empty string has height [#52](https://github.com/openkraken/kraken/pull/52)
- fix: cached percentage image has no size [#54](https://github.com/openkraken/kraken/pull/54)
- fix: fix set property to window did't refer to globalThis [#60](https://github.com/openkraken/kraken/pull/60)
- fix: box-shadow [#66](https://github.com/openkraken/kraken/pull/66)

**Feature**

- Feat: resize if viewport changed [#47](https://github.com/openkraken/kraken/pull/47)

## 0.6.6+2

- 修复 plugin 模块注册失败的问题

## 0.6.6+1

- 去除 patchKrakenPolyfill API

## 0.6.6

- 支持插件化方案，移除多余的依赖

## 0.6.6-dev.6

- 移除 WebSocket 依赖

## 0.6.6-dev.5

- 移除 webview 依赖

## 0.6.6-dev.4

- 修复 Hot Restart 之后，Event 对象销毁引发的 Crash

## 0.6.6-dev.3

- 修复 Hot Restart 之后，`patchKrakenPolyFill` 执行引发的 Crash

## 0.6.6-dev.2

- 移除 kraken_video_player
- 移除 MQTT 模块
- 移除 audio_player 依赖
- 移除 geolocation 依赖

## 0.6.0

**Features**

1. 重新设计并实现 Canvas
2. Bridge 支持派发异步任务到 Flutter UI 线程
3. 支持无限列表
4. 优化手势

**渲染能力**

1. input 支持 text-overflow: ellipsis
2. 添加 filter 能力
3. 支持 background-origin
4. 支持 background-clip

**其他**

1. 优化 Layout 和 Style 的计算性能
2. 优化 Bridge 实现
3. 兼容现有 Weex 已有的 JSC
4. 在测试环境中，提供模拟点击的 API
5. 优化多图场景下 Kraken 的首屏加载性能
6. 支持使用 Chrome DevTools 的 Element 面板来进行调试
7. scroller 实现 onscroll 事件


**BugFixs**

1. 修复 overflow scroll 时内容滚动到最后时滚动失效
2. 修复 background-attachment: local 无法生效
3. 修复 Input 通过 value 设置属性，输入框显示的值没有更新
4. 修复无 top 的 positioned element 的定位不对
5. 修复 hittest报错
6. 修复 transition 动画的启动时机问题
7. 修复动态更新 transition 属性，无法触发对应的动画
8. 修复align-items 与 align-self 某些组合 case 布局不正确
9. 修复无 top, left 有 margin 的 position absolute 元素在 flex container 中定位不准确
10. 修复设置 align-items: baseline 与 flex-wrap: wrap-reverse 时，baseline 对齐方向与 web 相反
11. 修复 flex-wrap: wrap 且 flex-item 未设置 width 时 flex container 会根据剩余 height 给 flex-item 自动分配 width
12. 修复 flex-item 设置 overflow: scroll 报错
13. 修复 flex-wrap 为 wrap 时 flex-item 的宽度超出 container
14. 修复 flex 中当 flex-item宽度总和大于 container 时，center, space-around, space-evenly 三种对齐方式 flex-item 应该整体居中展示
15. 修复 flex-flow 与 flex-wrap 同时设置时有时会报错
16. 修复 flex layout 下多层 div max-width 未生效
17. 修复 FlexContainer 作为滚动容器，会导致 cross 轴的滚动区域计算错误
18. 修复多 flex-item 设置 flex-shrink 导致 constraints 为负值出错
19. 修复 flex-shrink 负值不应该生效
20. 修复 flex-basis 与 width 同时存在时 flex-basis 优先级应该更高
21. 修复 flex-basis 为负值时报错
22. 修复多层 div 嵌套时内层 div 没有设置宽度时内部文本溢出
23. 修复容器 line-height 设置 0px 导致 children 定位不对
24. 修复 flex-direction column 与 flex-wrap wrap-reverse 同时存在时定位错误
25. 修复 flex layout 中 flex-wrap: wrap-reverse 且 flex-direction: column 时无 width 的 flex-item 未分配宽度
26. 修复 CSS url 地址不应该进行大小写转换
27. 修复 flex-layout 中 flex-shrink 过的 flex-item 设置 text-align: center 后 children 未居中展示
28. 修复 flex layout 中非整数的 flex-grow 未生效
29. 修复 flex layout align-content center 与 flex-grow 同时存在时 flex-item 位置不对
30. 修复 flex-wrap 为 wrap 的布局中 flex-item 高度不对
31. 修复 Fixed 元素没有固定在屏幕上
32. 修复 rax slider 动画异常
33. 修复使用 x-if 进行单页应用切换会导致 UI 线程运行超载，造成卡顿。
34. 修复 long-list 在两种实现的方式性能差距数倍问题
35. 修复 Canvas 绘制的坐标没有进行相对尺寸转换
36. 修复低版本 iOS 系统无法运行
37. 修复行内元素插入块级元素，border的渲染不正确
38. 修复绝对定位元素无法使用left:0, right:0, margin: auto 来实现水平居中


## 0.5.0

**Features**

**渲染能力**

1. 新增 position sticky
2. img 标签新增 width 和 height 属性支持
3. img 标签新增 base64 data url
4. Flexbox 支持 flex-wrap 属性
5. Flexbox 支持 align-self 属性
6. Flexbox 支持 flex, flex-flow 缩写属性
7. Flexbox align-content 支持 stretch 属性
8. 合并盒模型属性 padding, margin, border, background, overflow, opacity 到一个 RenderBoxModel 提升渲染性能
9. rgb 支持 rgb(40%, 40%, 40%) 百分比写法
10. rgb 支持 rgb(+128, 0, 0) 写法
11. 新增 line-height 支持
12. 新增 vertical-align 支持
13. 新增 margin auto 支持
14. 优化 border, background 渲染性能
15. 支持局部内容重绘提升滚动性能
16. 重构 transition 完整对齐 w3c 规范

**API**

1. 支持 vibrate API
2. Location API 对齐 w3c 规范
3. 新增 window.onerror event
4. 新增 document.all API
5. 新增 Image API
6. 新增 history API
7. 新增 a 标签支持
8. 添加跳转功能， 支持从 Kraken 内部页面跳转和从 Kraken 跳转到外部
9. 新增 document.getElementById API
10. 新增 document.getElementsByTagName API
11. 支持 background 缩写属性
12. 支持设置 scrollTop 与 scrollLeft
13. 支持 window.scrollTo, window.scroll, window.scrollBy API
14. asynStorage 支持 int 类型

**其他**

1. 支持 rax-components 自动化测试
2. 降级 android bridge API 到 level 16 支持 ARMV 7
3. 支持通过 widget 接入 Flutter 应用
4. 一个 Flutter 页面支持多页面 kraken 应用
5. 统一定义常量节省内存占用
6. 测试封装在 kraken widget 来跑，并行使用 2 个 widget 跑测试减少测试时间
7. 新增同层渲染能力支持
8. kraken widget 支持 onerror 回调
9. kraken widget match flutter widget 生命周期

**BugFixs**

1. 修复 relative 定位多帧渲染延迟
2. 修复 relative 容器无法滚动
3. 修复 flex item 无法通过 z-index 调整优先级
4. 修复 position 在 static 与 non static 之间切换逻辑缺失
5. 修复 transform 切换时动画不正确
6. 修复 background 属性不支持带空格的 rgb 值
7. 修复 CSSStyleDeclaration 占用内存过大
8. 修复 img 标签不支持直接设置宽度
9. 修复 padding, margin, border 等简写与非简写属性同时存在时未判断优先级
10. 修复由于定时器未清理导致 reload crash
11. 修复 input 无法正常工作
12. 修复 line-height 未支持 vw/vh 单位
13. 修复 border 为 0 仍然有 1px border 渲染出来
14. 修复 font 不支持的值报错
15. 修复 transitionStart 事件触发多次
16. 修复 kraken 与浏览器默认字体大小不一致
17. 修复多属性更改导致 transition 动画异常
18. 修复 overflow 区域未包含超出范围的绝对定位元素
19. 修复 Flex 容器嵌套时使用 padding 导致内部元素偏移不正确
20. 修复 borderRadius 在 overflow hidden 情况下未生效
21. 修复 padding 属性导致含有绝对定位元素的 flexbox 容器渲染异常
22. 修复 Flex 容器中内部元素无法触发滚动
23. 修复滚动容器内点击区域没有跟随滚动位置的问题
24. 修复滚动容器会影响内部没有设置 top left 属性的绝对定位元素的偏移
25. 修复flex item 无 width 时 flex item 宽度计算不正确问题
26. 修复 max-width 在定位、flex-item、inline 不应该生效
27. 修复滚动容器的高度计算没有按照所有内部元素的总高度来计算
28. 修复创建页面数量 > 8 个之后 crash
29. 修复页面销毁后内存泄漏
30. 修复 element 嵌套的某些情况下 baseline 对齐与浏览器不一致
31. 修复使用 transform 的动画会卡顿
32. 修复 bundlePath 加载页面会阻塞 Flutter 切换动画的运行
33. 修复 kraken_webview插件和webview_flutter插件注册重名的问题
34. 修复使用 transform 位移后的元素 hitTest 失效


## 0.4.0

**Features**

**渲染能力**

1. 支持 iframe 标签，并提供向内部 iframe 发送消息的API
2. 支持 rax-slider 组件
3. `<img />` 支持本地图片缓存和 lazyload 加载方式
4. `<img />` 支持 object-fit 和 object-position 属性
5. 完整支持 CSS transition 动画能力
6. 支持 CSS subtreeVisibility
7. 增加 Camera 摄像头渲染能力
8. 支持 background 简便写法
9. 支持 transitionend 事件
10. 支持 white-space: normal 和 nowrap
11. 支持 text-overflow: clip 和 ellipsis
12. 支持直接使用 Element 元素的内置属性来设置功能
13. video 支持使用 file:// 协议和 assets 路径
14. background-image: liner-gradient 支持多重 stop 格式
15. background-image: liner-gradient 支持 rgba 颜色
16. JSContext 支持抛出没有捕获的异常事件，可使用 window.unhandledrejection 来捕获
17. FlexItem 支持 flex-grow 和 flex-shrink 能力
18. 支持 align-content: flex-end
19. 添加 CSS initial 单位的支持
20. 添加内联元素内添加块级元素的渲染警告
21. 支持 flex 属性写法
22. 支持 flex-direction: column-reverse

**API**

1. 支持 Blob API
2. 支持 URL 和 URlSearchParams API
3. 提供基于 Flutter methodChannel 的 API，用于 JS 和客户端进行双向数据通信
4. 添加 navigation.userAgent API
5. 添加 performance API
6. 添加 Clipboard API
7. 将 window 设置为 JS 环境中的全局变量
8. 支持 mtop 请求，支持调用现有基于 mtop 的API
9. Kraken 下载 bundle 添加 query 参数支持
10. 支持 element.remove() API
11. 支持 CustomEvent API

**其他**

Kraken macOS 最小系统版本兼容到 macOS 10.12

**BugFixs**

1. 修复绝对定位元素的相对偏移基准和浏览器不一致的问题
2. 修复 border-radius 无法动态更新的问题
3. 修复 FlexLayout 中计算 layout 横向 size 时未区分 flex-direction 导致与纵向 size 的值相同
4. 修复 flex-grow 或者 flex-shrink 存在时 flex layout size 不正确
5. 修复动态切换绝对定位元素的 top left 属性而导致的渲染不正确
6. 修复 transform 默认的 origin 的位置与浏览器不一致的问题
7. 修复 dart 类型错误而导致的 fetch 调用超时问题
8. 修复 rax-image 设置错误的代码影响渲染的问题
9. 修复 Flex-item 会错误撑开自身宽度，从而影响其他元素位置的问题
10. 修复 JS Bridge 销毁时存在的内容泄漏问题
11. 修复动态更新文本节点渲染不生效的问题
12. 修复 transform: center top 水平居中不生效
13. 修复 transform: scale 只设置一个只，纵轴未缩放
14. 修复 rgba 写法，中间存在空格而导致的颜色解析失败
15. 修复 flex-item 元素上使用 text-align：center 失效的问题
16. 修复给空白文本节点设置 style 而导致的渲染异常
17. 修复 location.reload() 之后，上一个页面的 JSContext 没有销毁的问题
18. 修复 width 超出 max-width 的约束而导致的渲染异常
19. 修复 top: 0, bottom: 0 无法撑开元素的宽度问题
20. 修复 background 不支持线性渐变的问题
21. 修复 background-image 不支持 url('') 的写法
22. 修复 z-index 不支持负值的场景
23. 修复 Element.appendChild 时，因为没有移除已经被挂载的节点从而导致死循环的问题
24. 修复绝对定位元素的原始位置没有按照文档流的方式进行计算的问题
25. 修复 fixed 元素没有跟随 relative 父级相对位置的问题
26. 修复 linear-gradient 的角度计算错误问题
27. 修复 radial-graident 区域大小计算错误问题
28. 修复 mtop 跨域无法访问，增加简易的 document.cookie API 支持，允许设置 Origin Header
29. 修复 flexBox 下的多个 relative children 会重叠显示
30. 修复删除 relative element 时对应的 placeholder 未删掉导致 sibling 坐标错误
31. 修复 transform scale 的 origin 不正确
32. 修复有带有绝对定位的 image 图片计算后尺寸为 0
33. 修复 Rax 无法更新文本节点的问题
34. 修复 video 组件设置 loop 属性不生效的问题
35. 修复 FlexItem 在不设置高度的情况下，无法被 align-items: scretch 拉伸的问题
36. 修复 FlexItem 的高度超出外部约束的情况下，父级元素没有正确计算高度的问题
37. 修复 <img /> 如果没有设置 src 属性就无法设置宽高的问题
38. 修复 borderWidth 设置为 0 依然显示的问题
39. 修复 transition 存在的情况下，多个 transform 会导致动画失效的问题
40. 修复 input 未指定 width 时，默认宽度失效的问题
41. 修复 rgb 中的数值超出 0-255 限制而导致的渲染异常
42. 修复 十六进制颜色数值超出 0-255 限制到导致的渲染异常
