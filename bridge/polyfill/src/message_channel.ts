import {EventTarget} from 'event-target-shim';
import {krakenInvokeModule} from "./kraken";

const messageChannelMap = {};

export function dispatchMessageChannel(channelId: string, event: object) {
  let channel = messageChannelMap[channelId];
  if (channel) {
    channel.dispatchEvent(event);
  }
}

class MessageChannel extends EventTarget {
  private id: string;
  constructor(name: string) {
    super();
    this.id = krakenInvokeModule(JSON.stringify([
      'PlatformChannel',
      'init',
      name.toString()
    ]));
    messageChannelMap[this.id] = this;
  }

  invokeMethod(method: string, ...args: any[]): Promise<String> {
    return new Promise((resolve) => {
      krakenInvokeModule(JSON.stringify([
        'PlatformChannel',
        'method',
        this.id,
        method,
        JSON.stringify(args)
      ]), (result) => {
        resolve(result);
      })
    });
  }
}

Object.defineProperty(global, 'KrakenMessageChannel', {
  value: MessageChannel,
  enumerable: true,
  writable: false,
  configurable: false
});