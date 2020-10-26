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
declare const __kraken_request_animation_frame__: (callback: (timeStamp: DOMHighResTimeStamp) => void) => number;
declare const __kraken_to_blob__: (targetId: number, devicePixelRatio: number, callback: (err: string, blob: Blob) => void) => KrakenBlob;
declare const __kraken__: PrivateKraken;
export const krakenWindow = __kraken_window__;
export const krakenBlob = __kraken_blob__;
export const krakenToBlob = __kraken_to_blob__;
export const krakenRequestAnimationFrame = __kraken_request_animation_frame__;
export const privateKraken = __kraken__;

declare const __kraken_ui_manager__: (message: string) => string;
export const krakenUIManager = __kraken_ui_manager__;

declare const __kraken_ui_listener__: (fn: (message: string) => void) => void;
export const addKrakenUIListener = __kraken_ui_listener__;

declare const __kraken_invoke_module__: (message: string, fn?: (message: string) => void) => string;
export const krakenInvokeModule = __kraken_invoke_module__;

declare const __kraken_module_listener__: (fn: (message: string, done: (message?: string) => void) => void) => void;
export const addKrakenModuleListener = __kraken_module_listener__;

declare const __kraken_request_batch_update__: (fn: () => void) => void;
export const krakenRequestBatchUpdate = __kraken_request_batch_update__;

declare const __kraken_print__: (log: string, level?: string) => void;
export const krakenPrint = __kraken_print__;
