/**
 * Kraken: hook callback暴露
 */
#ifndef KRAKEN_HOOKS_H_
#define KRAKEN_HOOKS_H_

typedef void (*KrakenVoidCallback)(void*);

typedef void (*KrakenStringCallback)(const char*);

typedef struct {

  /**
   * dart isolate 已就绪，可以执行js代码
   */
  KrakenVoidCallback isolate_ready_callback;

  /**
   * dart回调js
   */
  KrakenStringCallback dart_to_js_callback;
} KrakenHooks;

#endif