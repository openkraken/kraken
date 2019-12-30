import {EventTarget, Event} from 'event-target-shim';

type OnMessageFunc = (event: MessageEvent) => void;
type OnOpenFunc = (event: Event) => void;
type OnCloseFunc = (event: Event) => void;
type OnErrorFunc = (event: Event) => void;
type KrakenToken = number;

// this interface is a description of the C++ Websocket API (bridge/bindings/websocket.cc)
interface KrakenWebSocket {
  connect: (
    url: string,
    onMessage: (message: string) => void,
    onOpen: () => void,
    onClose: (code: number, reason: string) => void,
    onError: (error: string) => void
  ) => KrakenToken;
  send: (token: KrakenToken, message: string | ArrayBuffer | ArrayBufferView) => void;
  close: (token: KrakenToken, code: number, reason: string) => void;
}

declare var __kraken_websocket__: KrakenWebSocket;

function validateUrl(url: string) {
  let protocol = url.substring(0, url.indexOf(':'));

  if (protocol !== 'ws' && protocol !== 'wss') {
    throw new Error(`Failed to construct 'WebSocket': The URL's scheme must be either 'ws' or 'wss'. '${protocol}' is not allowed.`);
  }
}

enum ReadyState {
  CONNECTING = 0,
  OPEN = 1,
  CLOSING = 2,
  CLOSED = 3
}

enum BinaryType {
  blob = 'blob',
  arraybuffer = 'arraybuffer'
}

function notImpl(name: string) {
  return () => {
    throw new Error(`${name} is not implemented`);
  }
}

class WebSocket extends EventTarget {
  private token: KrakenToken;
  public readyState: ReadyState;
  public CONNECTING = ReadyState.CONNECTING;
  public OPEN = ReadyState.OPEN;
  public CLOSING = ReadyState.CLOSING;
  public CLOSED = ReadyState.CLOSED;
  public url: string;
  public bufferAmount: number; // TODO add buffer amount support
  public extensions: string = ''; // TODO add extensions support
  public protocol: string = ''; // TODO add protocol support
  public binaryType: BinaryType = BinaryType.blob;
  public onopen: OnOpenFunc = notImpl('onopen');
  public onclose: OnCloseFunc = notImpl('onclose');
  public onerror: OnErrorFunc = notImpl('onerror');
  public onmessage: OnMessageFunc = notImpl('onmessage');

  private _onMessage = (message: string) => {
    this.dispatchEvent({
      type: 'message',
      // @ts-ignore
      data: message,
      // lastEventId: '', // TODO add lastEventId support
      // origin?: string; // TODO add origin support
      // ports?: MessagePort[]; // TODO add ports support
      // source?: MessageEventSource | null; // TODO add source support
    });
  };

  private _onOpen = () => {
    this.readyState = ReadyState.OPEN;
    this.dispatchEvent({
      type: 'open',
    });
  };

  private _onClose = (code: number, reason: string) => {
    this.readyState = ReadyState.CLOSED;
    this.dispatchEvent({
      type: 'event',
      code: code,
      reason: reason,
      wasClean: true // is close really clean ??
    });
  };

  private _onError = (error: string) => {
    let connectionStatus = '';

    switch (this.readyState) {
      case ReadyState.CLOSED: {
        connectionStatus = 'closed';
        break;
      }
      case ReadyState.OPEN: {
        connectionStatus = 'establishment';
        break;
      }
      case ReadyState.CONNECTING: {
        connectionStatus = 'establishment';
        break;
      }
    }

    console.error('WebSocket connection to \'' + this.url + '\' failed: ' +
      'Error in connection ' + connectionStatus + ': ' + error);
    this.dispatchEvent({
      type: 'error'
    });
    this.readyState = ReadyState.CLOSED;
  };

  constructor(url: string, protocol: string | string[]) {
    super();
    // verify url schema
    validateUrl(url);

    this.url = url;
    this.readyState = 0;

    this.token = __kraken_websocket__.connect(url, this._onMessage, this._onOpen, this._onClose, this._onError);
  }

  // TODO add blob arrayBuffer ArrayBufferView format support
  public send(message: string | ArrayBuffer | ArrayBufferView) {
    __kraken_websocket__.send(this.token, message);
  }

  public close(code: number, reason: string) {
    this.readyState = ReadyState.CLOSING;
    __kraken_websocket__.close(this.token, code, reason);
  }
}

//@ts-ignore
// prevent user override buildin WebSocket class
Object.defineProperty(global, 'WebSocket', {
  enumerable: true,
  writable: false,
  value: WebSocket,
  configurable: false
});
