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

declare const __kraken_window__: KrakenWindow;
export const krakenWindow = __kraken_window__;

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

declare const __kraken_ui_manager__: (message: string) => void;
export const krakenUIManager = __kraken_ui_manager__;

declare const __kraken_ui_listener__: (fn: (message: string) => void) => void;
export const krakenUIListener = __kraken_ui_listener__;

declare const __kraken_invoke_module__: (message: string, fn?: (message: string) => void) => string;
export const krakenInvokeModule = __kraken_invoke_module__;

declare const __kraken_module_listener__: (fn: (message: string) => void) => void;
export const krakenModuleListener = __kraken_module_listener__;
