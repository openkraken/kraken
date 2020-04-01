import { EventTarget } from 'event-target-shim';
import { krakenInvokeModule } from './kraken';

enum ReadyState {
  CONNECTING = 0,
  OPEN = 1,
  CLOSING = 2,
  CLOSED = 3
}

// Quality of Service (QoS) in MQTT messaging is an agreement between sender
// and receiver on the guarantee of delivering a message.
enum QoS {
  AT_MOST_ONCE = 0,
  AT_LEAST_ONCE = 1,
  EXACTLY_ONCE = 2,
}

const mqttClientMap = {};

export function dispatchMQTT (clientId: string, event: object) {
  let client = mqttClientMap[clientId];
  if (client) {
    client.dispatchEvent(event); 
  }
}

class MQTT extends EventTarget {
  CONNECTING = ReadyState.CONNECTING;
  OPEN = ReadyState.OPEN;
  CLOSING = ReadyState.CLOSING;
  CLOSED = ReadyState.CLOSED;

  private id: string;
  url: string;

  constructor(url: string, clientId: string = '') {
    super();
    this.url = url;
    this.id = krakenInvokeModule(`["MQTT","init",["${url}","${clientId}"]]`);
    mqttClientMap[this.id] = this;
  }

  private _onopen: any = null;
  private _onmessage: any = null;
  private _onclose: any = null;
  private _onerror: any = null;
  private _onpublish: any = null;
  private _onsubscribe: any = null;
  private _onunsubscribe: any = null;
  private _onsubscribeerror: any = null;

  set onopen(messageHandler: any) {
    if (this._onopen) {
      this.removeEventListener('open', this._onopen);
    }
    this._onopen = messageHandler;
    this.addEventListener('open', messageHandler);
  }

  get onopen() {
    return this._onopen;
  }

  set onclose(messageHandler: any) {
    if (this._onclose) {
      this.removeEventListener('close', this._onclose);
    }
    this._onclose = messageHandler;
    this.addEventListener('close', messageHandler);
  }

  get onclose() {
    return this._onclose;
  }

  set onmessage(messageHandler: any) {
    if (this._onmessage) {
      this.removeEventListener('message', this._onmessage);
    }
    this._onmessage = messageHandler;
    this.addEventListener('message', messageHandler);
  }

  get onmessage() {
    return this._onmessage;
  }

  set onerror(messageHandler: any) {
    if (this._onerror) {
      this.removeEventListener('error', this._onerror);
    }
    this._onerror = messageHandler;
    this.addEventListener('error', messageHandler);
  }

  get onerror() {
    return this._onerror;
  }

  set onpublish(messageHandler: any) {
    if (this._onpublish) {
      this.removeEventListener('publish', this._onpublish);
    }
    this._onpublish = messageHandler;
    this.addEventListener('publish', messageHandler);
  }

  get onpublish() {
    return this._onpublish;
  }

  set onsubscribe(messageHandler: any) {
    if (this._onsubscribe) {
      this.removeEventListener('subscribe', this._onsubscribe);
    }
    this._onsubscribe = messageHandler;
    this.addEventListener('subscribe', messageHandler);
  }

  get onsubscribe() {
    return this._onsubscribe;
  }

  set onunsubscribe(messageHandler: any) {
    if (this._onunsubscribe) {
      this.removeEventListener('unsubscribe', this._onunsubscribe);
    }
    this._onunsubscribe = messageHandler;
    this.addEventListener('unsubscribe', messageHandler);
  }

  get onunsubscribe() {
    return this._onunsubscribe;
  }

  set onsubscribeerror(messageHandler: any) {
    if (this._onsubscribeerror) {
      this.removeEventListener('subscribeerror', this._onsubscribeerror);
    }
    this._onsubscribeerror = messageHandler;
    this.addEventListener('subscribeerror', messageHandler);
  }

  get onsubscribeerror() {
    return this._onsubscribeerror;
  }

  addEventListener(type: string, callback: any) {
    krakenInvokeModule(`["MQTT","addEvent",["${this.id}","${type}"]]`);
    super.addEventListener(type, callback);
  }

  get readyState() {
    var state = krakenInvokeModule(`["MQTT","getReadyState",["${this.id}"]]`);
    return parseInt(state);
  }

  // Client requests a connection to a Server
  open(options: { QoS?: QoS, username?: string, password?: string, keepalive?: number} = {}) {
    krakenInvokeModule(`["MQTT","open",["${this.id}",${JSON.stringify(options)}]]`);
  }
  // Subscribe to topics
  subscribe(topic: string, options: { QoS?: QoS} = {}) {
    krakenInvokeModule(`["MQTT","subscribe",["${this.id}","${topic}",${options.QoS || QoS.AT_MOST_ONCE}]]`);
  }
  // Unsubscribe from topics
  unsubscribe(topic: string) {
    krakenInvokeModule(`["MQTT","unsubscribe",["${this.id}","${topic}"]]`);
  }
  // Publish message
  publish(topic: string, message: string, options: { QoS?: QoS, retain?: boolean} = {}) {
    krakenInvokeModule(`["MQTT","publish",["${this.id}","${topic}","${message}",${options.QoS || QoS.AT_MOST_ONCE},${options.retain || false}]]`);
  }
  // Disconnect notification
  close() {
    krakenInvokeModule(`["MQTT","close",["${this.id}"]]`);
    mqttClientMap[this.id] = null;
  }
}

Object.defineProperty(global, 'MQTT', {
  enumerable: true,
  writable: false,
  value: MQTT,
  configurable: false
});

