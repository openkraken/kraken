import { NodeImpl, NodeType, nodeMap } from './node';
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

export function handleEvent(nodeId: number, event: any) {
  const currentTarget = nodeMap[nodeId];
  const target = nodeMap[event.target];
  event.targetId = event.target;
  event.target = target;

  event.currentTargetId = event.currentTarget;
  event.currentTarget = currentTarget;

  if (currentTarget) {
    currentTarget.dispatchEvent(event);
  }
}

export class ElementImpl extends NodeImpl {
  public readonly tagName: string;
  private events: {
    [eventName: string]: any;
  } = {};
  public style: object = {};

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
    setProperty(this.nodeId, name, value);
  }

  public click() {
    method(this.nodeId, 'click');
  }
}
