import { EventTarget, Event } from './document/event-target';
import { krakenInvokeModule } from './bridge';

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

export class MQTT extends EventTarget {
  CONNECTING = ReadyState.CONNECTING;
  OPEN = ReadyState.OPEN;
  CLOSING = ReadyState.CLOSING;
  CLOSED = ReadyState.CLOSED;

  private id: string;
  url: string;

  constructor(url: string, clientId: string = '') {
    super(undefined, ['open', 'message', 'close', 'error', 'publish', 'subscribe', 'unsubscribe', 'subscribeerror']);
    this.url = url;
    this.id = krakenInvokeModule(JSON.stringify(['MQTT', 'init', [url, clientId]]));
    mqttClientMap[this.id] = this;
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
    krakenInvokeModule(JSON.stringify(['MQTT', 'subscribe', [this.id, topic, options.QoS || QoS.AT_MOST_ONCE]]));
  }
  // Unsubscribe from topics
  unsubscribe(topic: string) {
    krakenInvokeModule(JSON.stringify(['MQTT', 'unsubscribe', [this.id, topic]]));
  }
  // Publish message
  publish(topic: string, message: string, options: { QoS?: QoS, retain?: boolean} = {}) {
    krakenInvokeModule(JSON.stringify(['MQTT', 'publish', [this.id, topic, message, options.QoS || QoS.AT_MOST_ONCE, options.retain || false]]));
  }
  // Disconnect notification
  close() {
    krakenInvokeModule(`["MQTT","close",["${this.id}"]]`);
    mqttClientMap[this.id] = null;
  }
}
