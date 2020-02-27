import { NodeImpl, NodeType } from './node';
import {
  addEvent,
  createElement,
  removeEvent,
  setProperty,
  setStyle,
  method
} from './UIManager';

type EventListener = () => void;

let nodeMap: {
  [nodeId: number]: ElementImpl;
} = {};

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

export class ElementImpl extends NodeImpl {
  public readonly tagName: string;
  private events: {
    [eventName: string]: EventListener;
  } = {};
  public style: object = {};

  constructor(tagName: string, id: number) {
    super(NodeType.ELEMENT_NODE, id);
    this.tagName = tagName.toUpperCase();

    this.style = new Proxy(this.style, {
      set(target: any, key: string, value: any, receiver: any): boolean {
        this[key] = value;
        setStyle(id, key, value);
        return value;
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
        enumerable: false,
        get() {
          return Number(method(this.id, prop, []));
        },
      });
    }

    if (tagName != 'BODY') {
      createElement(this.tagName, id, {}, []);
    }
  }

  addEventListener(eventName: string, eventListener: any) {
    super.addEventListener(eventName, eventListener);
    addEvent(this.id, eventName);
    this.events[eventName] = eventListener;
    nodeMap[this.id] = this;
  }

  removeEventListener(eventName: string, eventListener: any) {
    super.removeEventListener(eventName, eventListener);
    delete nodeMap[this.id];
    delete this.events[eventName];
    removeEvent(this.id, eventName);
  }

  getBoundingClientRect = () => {
    const rectInformation = method(this.id, 'getBoundingClientRect', []);
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
    setProperty(this.id, name, value);
  }
}
