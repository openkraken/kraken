import {initPropertyHandlersForEventTargets} from "../helpers";
import {kraken} from "../kom/kraken";

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

export function dispatchMQTTEvent(clientId: string, event: Event) {
  let client = mqttClientMap[clientId];
  if (client) {
    client.dispatchEvent(event);
  }
}

const builtInEvents = ['open', 'message', 'close', 'error', 'publish', 'subscribe', 'unsubscribe', 'subscribeerror'];

export class MQTT extends EventTarget {
  CONNECTING = ReadyState.CONNECTING;
  OPEN = ReadyState.OPEN;
  CLOSING = ReadyState.CLOSING;
  CLOSED = ReadyState.CLOSED;

  private id: string;
  url: string;

  constructor(url: string, clientId: string = '') {
    // @ts-ignore
    super(builtInEvents);
    this.url = url;
    this.id = kraken.invokeModule('MQTT', 'init', ([url, clientId]));
    mqttClientMap[this.id] = this;

    initPropertyHandlersForEventTargets(this, builtInEvents);
  }

  addEventListener(type: string, callback: any) {
    kraken.invokeModule('MQTT', 'addEvent', [this.id, type]);
    super.addEventListener(type, callback);
  }

  get readyState() {
    var state = kraken.invokeModule('MQTT', 'getReadyState', [this.id]);
    return parseInt(state);
  }

  // Client requests a connection to a Server
  open(options: { QoS?: QoS, username?: string, password?: string, keepalive?: number} = {}) {
    kraken.invokeModule('MQTT', 'open', [this.id, options]);
  }
  // Subscribe to topics
  subscribe(topic: string, options: { QoS?: QoS} = {}) {
    kraken.invokeModule('MQTT', 'subscribe', ([this.id, topic, options.QoS || QoS.AT_MOST_ONCE]));
  }
  // Unsubscribe from topics
  unsubscribe(topic: string) {
    kraken.invokeModule('MQTT', 'unsubscribe', ([this.id, topic]));
  }
  // Publish message
  publish(topic: string, message: string, options: { QoS?: QoS, retain?: boolean} = {}) {
    kraken.invokeModule('MQTT', 'publish', ([this.id, topic, message, options.QoS || QoS.AT_MOST_ONCE, options.retain || false]));
  }
  // Disconnect notification
  close() {
    kraken.invokeModule('MQTT','close',[this.id]);
    mqttClientMap[this.id] = null;
  }
}
