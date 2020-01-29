/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_EXPORT_H
#define KRAKEN_BRIDGE_EXPORT_H

#include <cstdint>
#define KRAKEN_EXPORT                                                          \
  extern "C" __attribute__((visibility("default"))) __attribute__((used))

KRAKEN_EXPORT
void initJsEngine();
KRAKEN_EXPORT
void evaluateScripts(const char *code, const char *bundleFilename,
                     int startLine);
KRAKEN_EXPORT
void reloadJsContext();
KRAKEN_EXPORT
void invokeKrakenCallback(const char *data);
KRAKEN_EXPORT
void registerInvokeDartFromJS(InvokeDartFromJS invokeDartFromJs);
KRAKEN_EXPORT
void registerReloadApp(ReloadApp reloadApp);
KRAKEN_EXPORT
void registerSetTimeout(SetTimeout setTimeout);
KRAKEN_EXPORT
void registerSetInterval(SetInterval setInterval);
KRAKEN_EXPORT
void registerClearTimeout(ClearTimeout clearTimeout);
KRAKEN_EXPORT
void registerRequestAnimationFrame(RequestAnimationFrame requestAnimationFrame);
KRAKEN_EXPORT
void registerCancelAnimationFrame(CancelAnimationFrame cancelAnimationFrame);
KRAKEN_EXPORT
void registerGetScreen(GetScreen getScreen);
KRAKEN_EXPORT
Screen *createScreen(double width, double height);

#endif // KRAKEN_BRIDGE_EXPORT_H
