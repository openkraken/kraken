/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

declare const __webf_invoke_module__: (module: string, method: string, params?: Object | null, fn?: (err: Error, data: any) => void) => string;
export const webfInvokeModule = __webf_invoke_module__;

declare const __webf_module_listener__: (fn: (moduleName: string, event: Event, extra: string) => void) => void;
export const addWebfModuleListener = __webf_module_listener__;

declare const __webf_print__: (log: string, level?: string) => void;
export const webfPrint = __webf_print__;
