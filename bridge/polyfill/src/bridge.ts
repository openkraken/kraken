export interface KrakenLocation {
  reload: () => void;
  href: string;
}

export interface KrakenWindow {
  onLoad: any;
  onColorSchemeChange: any;
  devicePixelRatio: number;
  colorScheme: string;
  location: KrakenLocation;
  parent: any;
}

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
  userAgent: string;
}

declare const __kraken_window__: KrakenWindow;
declare const __kraken_blob__: (blobParts?: KrakenBlob[], options?: BlobPropertyBag) => KrakenBlob;
declare const __kraken__: PrivateKraken;
export const krakenWindow = process.env.ENABLE_JSA ? __kraken_window__ : window;
export const krakenBlob = __kraken_blob__;
export const privateKraken = __kraken__;

declare const __kraken_invoke_module__: (message: string, fn?: (message: string) => void) => string;
export const krakenInvokeModule = __kraken_invoke_module__;

declare const __kraken_module_listener__: (fn: (message: string, done: (message?: string) => void) => void) => void;
export const addKrakenModuleListener = __kraken_module_listener__;

declare const __kraken_print__: (log: string, level?: string) => void;
export const krakenPrint = __kraken_print__;
