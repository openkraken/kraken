import { EventTarget, Event } from './document/event-target';
import { KrakenWebSocketToken, krakenWebSocket} from './bridge';

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

class WebSocket extends EventTarget {
  private token: KrakenWebSocketToken;
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

  private _onMessage = (message: string) => {
    const event = new Event('message');
    Object.assign(event, {
      data: message,
      // lastEventId: '', // TODO add lastEventId support
      // origin?: string; // TODO add origin support
      // ports?: MessagePort[]; // TODO add ports support
      // source?: MessageEventSource | null; // TODO add source support
    });
    this.dispatchEvent(event);
  };

  private _onOpen = () => {
    this.readyState = ReadyState.OPEN;
    this.dispatchEvent(new Event('open'));
  };

  private _onClose = (code: number, reason: string) => {
    this.readyState = ReadyState.CLOSED;
    const event = new Event('close');
    Object.assign(event, {
      code: code,
      reason: reason,
      wasClean: true // is close really clean ??
    });
    this.dispatchEvent(event);
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
    this.dispatchEvent(new Event('error'));
    this.readyState = ReadyState.CLOSED;
  };

  public _onopen: any = null;
  public _onmessage: any = null;
  public _onclose: any = null;
  public _onerror: any = null;

  public set onopen(messageHandler: any) {
    if (this._onopen) {
      this.removeEventListener('open', this._onopen);
    }
    this._onopen = messageHandler;
    this.addEventListener('open', messageHandler);
  }

  public get onopen() {
    return this._onopen;
  }

  public set onclose(messageHandler: any) {
    if (this._onclose) {
      this.removeEventListener('close', this._onclose);
    }
    this._onclose = messageHandler;
    this.addEventListener('close', messageHandler);
  }

  public get onclose() {
    return this._onclose;
  }

  public set onmessage(messageHandler: any) {
    if (this._onmessage) {
      this.removeEventListener('message', this._onmessage);
    }
    this._onmessage = messageHandler;
    this.addEventListener('message', messageHandler);
  }

  public get onmessage() {
    return this._onmessage;
  }

  public set onerror(messageHandler: any) {
    if (this._onerror) {
      this.removeEventListener('error', this._onerror);
    }
    this._onerror = messageHandler;
    this.addEventListener('error', messageHandler);
  }

  public get onerror() {
    return this._onerror;
  }

  constructor(url: string, protocol: string | string[]) {
    super();
    // verify url schema
    validateUrl(url);

    this.url = url;
    this.readyState = 0;

    this.token = krakenWebSocket.connect(url, this._onMessage, this._onOpen, this._onClose, this._onError);
  }

  // TODO add blob arrayBuffer ArrayBufferView format support
  public send(message: string | ArrayBuffer | ArrayBufferView) {
    krakenWebSocket.send(this.token, message);
  }

  public close(code: number, reason: string) {
    this.readyState = ReadyState.CLOSING;
    krakenWebSocket.close(this.token, code, reason);
  }
}

Object.defineProperty(global, 'WebSocket', {
  enumerable: true,
  writable: false,
  value: WebSocket,
  configurable: false
});
