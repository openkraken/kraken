import { initPropertyHandlersForEventTargets } from './helpers';
import { kraken } from './kraken';

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

const wsClientMap = {};

export function dispatchWebSocketEvent(clientId: string, event: ErrorEvent) {
  let client = wsClientMap[clientId];
  if (client) {
    let readyState = client.readyState;
    switch(event.type) {
      case 'open':
        readyState = ReadyState.OPEN;
        break;
      case 'close':
        readyState = ReadyState.CLOSED;
        break;
      case 'error':
        readyState = ReadyState.CLOSED;
        let connectionStatus = '';
        switch (readyState) {
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
        console.error('WebSocket connection to \'' + client.url + '\' failed: ' +
        'Error in connection ' + connectionStatus + ': ' + event.error);
        break;
    }
    client.readyState = readyState;
    client.dispatchEvent(event);
  }
}

const builtInEvents = [
  'open', 'close', 'message', 'error'
];

export class WebSocket extends EventTarget {
  private id: string;
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

  constructor(url: string, protocol: string | string[]) {
    // @ts-ignore
    super(builtInEvents);
    // verify url schema
    validateUrl(url);

    this.url = url;
    this.readyState = ReadyState.CONNECTING;

    this.id = kraken.invokeModule('WebSocket', 'init', url);
    wsClientMap[this.id] = this;

    initPropertyHandlersForEventTargets(this, builtInEvents);
  }

  addEventListener(type: string, callback: any) {
    kraken.invokeModule('WebSocket', 'addEvent', ([this.id, type]))
    super.addEventListener(type, callback);
  }

  // TODO add blob arrayBuffer ArrayBufferView format support
  public send(message: string) {
    kraken.invokeModule('WebSocket', 'send', ([this.id, message]))
  }

  public close(code: number, reason: string) {
    this.readyState = ReadyState.CLOSING;
    kraken.invokeModule('WebSocket', 'close', ([this.id, code, reason]));
  }
}
