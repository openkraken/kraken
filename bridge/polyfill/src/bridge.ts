
export interface KrakenBlob {
  size: number;
  type: string;
  slice(start?: number, end?: number, contentType?: string): KrakenBlob;
  text(): string;
  arrayBuffer(): ArrayBuffer;
}

export interface PrivateKraken {
  appName: string;
  appVersion: string;
  platform: string;
  product: string;
  productSub: string;
  comment: string;
}

declare const __kraken_invoke_module__: (module: string, method: string, params?: Object | null, fn?: (err: Error, data: any) => void) => string;
export const krakenInvokeModule = __kraken_invoke_module__;

declare const __kraken_add_module_listener__: (fn: (moduleName: string, event: Event, extra: string) => void) => void;
export const addKrakenModuleListener = __kraken_add_module_listener__;

declare const __kraken_print__: (log: string, level?: string) => void;
export const krakenPrint = __kraken_print__;
