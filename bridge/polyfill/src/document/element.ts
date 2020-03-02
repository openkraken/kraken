import { Node, NodeType } from './node';
import {
  addEvent,
  createElement,
  setProperty,
  removeProperty,
  setStyle,
  method,
  requestUpdateFrame
} from './UIManager';
import {krakenToBlob} from '../kraken';
import {Blob} from "../blob";

const RECT_PROPERTIES = [
  'offsetTop',
  'offsetLeft',
  'offsetWidth',
  'offsetHeight',

  'clientWidth',
  'clientHeight',
  'clientLeft',
  'clientTop',

  'scrollTop',
  'scrollLeft',
  'scrollHeight',
  'scrollWidth',
];

export class Element extends Node {
  public readonly tagName: string;
  private events: {
    [eventName: string]: any;
  } = {};
  public style: object = {};
  // TODO use NamedNodeMap: https://developer.mozilla.org/en-US/docs/Web/API/NamedNodeMap
  public attributes: Array<any> = [];

  constructor(tagName: string, _nodeId?: number) {
    super(NodeType.ELEMENT_NODE, _nodeId);
    this.tagName = tagName.toUpperCase();
    const nodeId = this.nodeId;
    this.style = new Proxy(this.style, {
      set(target: any, key: string, value: any, receiver: any): boolean {
        this[key] = value;
        setStyle(nodeId, key, value);
        return true;
      },
      get(target: any, key: string, receiver) {
        return this[key];
      },
    });

    // Define rect properties
    for (let i = 0; i < RECT_PROPERTIES.length; i++) {
      const prop = RECT_PROPERTIES[i];
      Object.defineProperty(this, prop, {
        configurable: false,
        enumerable: true,
        get() {
          return Number(method(nodeId, prop));
        },
      });
    }

    if (tagName != 'BODY') {
      createElement(this.tagName, nodeId, {}, []);
    }
  }

  addEventListener(eventName: string, eventListener: any) {
    super.addEventListener(eventName, eventListener);
    if (!this.events.hasOwnProperty(eventName)) {
      addEvent(this.nodeId, eventName);
      this.events[eventName] = eventListener;
    }
  }

  // Do not really emit remove event, due to performance consideration.
  removeEventListener(eventName: string, eventListener: any) {
    super.removeEventListener(eventName, eventListener);
  }

  getBoundingClientRect = () => {
    const rectInformation = method(this.nodeId, 'getBoundingClientRect');
    if (typeof rectInformation === 'string') {
      return JSON.parse(rectInformation);
    } else {
      return null;
    }
  }

  get nodeName() {
    return this.tagName.toUpperCase();
  }

  public setAttribute(name: string, value: string) {
    name = String(name);
    value = String(value);
    if (this.attributes[name]) {
      this.attributes[name].value = value;
    } else {
      const attr = {name, value};
      this.attributes[name] = attr;
      this.attributes.push(attr);
    }

    setProperty(this.nodeId, name, value);
  }

  public getAttribute(name: string) {
    name = String(name);
    if (this.attributes[name]) {
      return this.attributes[name].value;
    }
  }

  public hasAttribute(name: string) {
    name = String(name);
    return Boolean(this.attributes[name]);
  }

  public removeAttribute(name: string) {
    if (this.attributes[name]) {
      const attr = this.attributes[name];
      const idx = this.attributes.indexOf(attr);
      if (idx !== -1) {
        this.attributes.splice(idx, 1);
      }

      removeProperty(this.nodeId, name);
      delete this.attributes[name];
    }
  }

  public click() {
    method(this.nodeId, 'click');
  }

  async toBlob() {
    // need to flush all pending frame messages
    requestUpdateFrame();
    return new Promise((resolve, reject) => {
      krakenToBlob(this.nodeId, (err, blob) => {
        if (err) {
          return reject(new Error(err));
        }

        resolve(new Blob([blob]));
      });
    });
  }
}
