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
      }
    });

    // define properties
    Object.defineProperty(this, 'offsetTop', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'offsetTop', []);
      }
    });

    Object.defineProperty(this, 'offsetLeft', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'offsetLeft', []);
      }
    });

    Object.defineProperty(this, 'offsetWidth', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'offsetWidth', []);
      }
    });

    Object.defineProperty(this, 'offsetHeight', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'offsetHeight', []);
      }
    });

    Object.defineProperty(this, 'clientWidth', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'clientWidth', []);
      }
    });

    Object.defineProperty(this, 'clientHeight', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'clientHeight', []);
      }
    });

    Object.defineProperty(this, 'clientLeft', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'clientLeft', []);
      }
    });

    Object.defineProperty(this, 'clientTop', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'clientTop', []);
      }
    });

    Object.defineProperty(this, 'scrollTop', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'scrollTop', []);
      }
    });

    Object.defineProperty(this, 'scrollLeft', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'scrollLeft', []);
      }
    });

    Object.defineProperty(this, 'scrollHeight', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'scrollHeight', []);
      }
    });

    Object.defineProperty(this, 'scrollWidth', {
      configurable: false,
      enumerable: false,
      set(v) {
        console.warn('this property is only readable');
      },
      get() {
        return method(this.id, 'scrollWidth', []);
      }
    });

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
    return method(this.id, 'getBoundingClientRect', []);
  }

  get nodeName() {
    return this.tagName.toUpperCase();
  }

  public setAttribute(name: string, value: string) {
    setProperty(this.id, name, value);
  }
}
