import { Node, NodeType, getNodeById } from './node';
import {
  addEvent,
  createElement,
  setProperty,
  setStyle,
  method
} from './UIManager';

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

export function handleEvent(currentTarget: Node, event: any) {
  const target = getNodeById(event.target);
  event.targetId = event.target;
  event.target = target;

  event.currentTargetId = event.currentTarget;
  event.currentTarget = currentTarget;

  if (currentTarget) {
    currentTarget.dispatchEvent(event);
  }
}

export class Element extends Node {
  public readonly tagName: string;
  private events: {
    [eventName: string]: any;
  } = {};
  public style: object = {};

  constructor(tagName: string, id?: number) {
    super(NodeType.ELEMENT_NODE, id);
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

  _hasEvent(eventName: string) {
    return this.events.hasOwnProperty(eventName);
  }

  addEventListener(eventName: string, eventListener: any) {
    super.addEventListener(eventName, eventListener);
    if (!this._hasEvent(eventName)) {
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
    setProperty(this.nodeId, name, value);
  }

  public click() {
    method(this.nodeId, 'click');
  }
}
