export interface KrakenLocation {
  reload: () => void;
  origin: string;
  protocol: string;
  host: string;
  hostname: string;
  port: string;
  pathname: string;
  search: string;
  hash: string;
}

export interface KrakenWindow {
  onLoad: any;
  onColorSchemeChange: any;
  devicePixelRatio: number;
  colorScheme: string;
  location: KrakenLocation;
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
}

declare const __kraken_window__: KrakenWindow;
declare const __kraken_blob__: (blobParts?: BlobPart[], options?: BlobPropertyBag) => KrakenBlob;
declare const __kraken_request_animation_frame__: (callback: (timeStamp: DOMHighResTimeStamp) => void) => number;
declare const __kraken_to_blob__: (nodeId: number, devicePixelRatio: number, callback: (err: string, blob: Blob) => void) => KrakenBlob;
declare const __kraken__: PrivateKraken;
export const krakenWindow = __kraken_window__;
export const krakenBlob = __kraken_blob__;
export const krakenToBlob = __kraken_to_blob__;
export const krakenRequestAnimationFrame = __kraken_request_animation_frame__;
export const privateKraken = __kraken__;

export type KrakenWebSocketToken = number;

// this interface is a description of the C++ Websocket API (bridge/bindings/websocket.cc)
export interface KrakenWebSocket {
  connect: (
    url: string,
    onMessage: (message: string) => void,
    onOpen: () => void,
    onClose: (code: number, reason: string) => void,
    onError: (error: string) => void
  ) => KrakenWebSocketToken;
  send: (token: KrakenWebSocketToken, message: string | ArrayBuffer | ArrayBufferView) => void;
  close: (token: KrakenWebSocketToken, code: number, reason: string) => void;
}

declare const __kraken_websocket__: KrakenWebSocket;
export const krakenWebSocket = __kraken_websocket__;

declare const __kraken_ui_manager__: (message: string) => void|string;
export const krakenUIManager = __kraken_ui_manager__;

declare const __kraken_ui_listener__: (fn: (message: string) => void) => void;
export const krakenUIListener = __kraken_ui_listener__;

declare const __kraken_invoke_module__: (message: string, fn?: (message: string) => void) => string;
export const krakenInvokeModule = __kraken_invoke_module__;

declare const __kraken_module_listener__: (fn: (message: string) => void) => void;
export const krakenModuleListener = __kraken_module_listener__;

declare const __kraken_request_batch_update__: (fn: () => void) => void;
export const krakenRequestBatchUpdate = __kraken_request_batch_update__;

declare const __kraken_print__: (log: string, level?: string) => void;
export const krakenPrint = __kraken_print__;
