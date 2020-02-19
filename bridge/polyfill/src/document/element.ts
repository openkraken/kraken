import { NodeImpl, NodeType } from './node';
import {
  addEvent,
  createElement,
  removeEvent,
  setProperty,
  setStyle
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

  private toCamelCase(key: string) {
    let  strArray = key.split(/_|-/);
    let humpStr = strArray[0];
    for (let i = 1, l = strArray.length; i < l; i+=1) {
      humpStr += strArray[i].slice(0, 1).toUpperCase() + strArray[i].slice(1);
    }
    return humpStr;
  }

  constructor(tagName: string, id: number) {
    super(NodeType.ELEMENT_NODE, id);
    this.tagName = tagName.toUpperCase();
    const toCamelCase = this.toCamelCase;

    this.style = new Proxy(this.style, {
      set(target: any, p: string | number | symbol, value: any, receiver: any): boolean {
        let styleKey = toCamelCase(String(p));
        this[styleKey] = value;
        setStyle(id, styleKey, value);
        return true;
      },
      get(target: any, props: string | number | symbol, receiver) {
        let styleKey = toCamelCase(String(props));
        return this[styleKey];
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

  get nodeName() {
    return this.tagName.toUpperCase();
  }

  public setAttribute(name: string, value: string) {
    setProperty(this.id, name, value);
  }
}
