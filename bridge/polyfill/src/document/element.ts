import { Node, NodeType } from './node';
import {
  addEvent,
  createElement,
  setProperty,
  removeProperty,
  setStyle,
  method,
  toBlob
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

interface ICamelize {
  (str: string): string;
}

/**
 * Create a cached version of a pure function.
 */
function cached(fn: ICamelize) {
  const cache = Object.create(null);
  return function cachedFn(str : string) {
    const hit = cache[str];
    return hit || (cache[str] = fn(str));
  };
};

/**
 * Camelize a hyphen-delimited string.
 */
const camelize: ICamelize = (str: string) => {
  const camelizeRE = /-(\w)/g;
  return str.replace(camelizeRE, function(_ : string, c : string) {
    return c ? c.toUpperCase() : '';
  });
}

// Cached camelize utility
const cachedCamelize = cached(camelize);

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
        const cKey = cachedCamelize(key);
        this[cKey] = value;
        setStyle(nodeId, cKey, value);
        return true;
      },
      get(target: any, key: string, receiver) {
        const cKey = cachedCamelize(key);
        return this[cKey];
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
    // The attribute name is automatically converted to
    // all lower-case when setAttribute() is called on an HTML element in an HTML document
    name = String(name).toLowerCase();
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

  async toBlob(devicePixelRatio: number = window.devicePixelRatio) {
    return toBlob(this.nodeId, devicePixelRatio);
  }

  public scroll(x: number | any, y?: number) {
    let option = x;
    if (typeof x === 'number') {
      option = {
        'top': y,
        'left': x
      };
    }
    method(this.nodeId, 'scroll', [option]);
  }

  public scrollTo(x: number | any, y?: number) {
    if (typeof y === "number") {
      scroll(x, y);
    } else {
      scroll(x, 0);
    }
  }

  public scrollBy(x: number | any, y?: number) {
    let option = x;
    if (typeof x === 'number') {
      option = {
        'top': y,
        'left': x
      };
    }
    method(this.nodeId, 'scrollBy', [option]);
  }
}
