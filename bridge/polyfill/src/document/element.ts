import {NodeImpl, NodeType} from './node';
import {
  krakenAddEvent,
  krakenCreateElement,
  krakenRemoveEvent,
  krakenSetProperty,
  krakenSetStyle,
} from './kraken';

declare var __kraken_dart_to_js__: (fn: (message: string) => void) => void;
type EventListener = () => void;

let nodeMap: {
  [nodeId: number]: ElementImpl;
} = {};
const TARGET_JS = 'J';

__kraken_dart_to_js__((message) => {
  if (message[1] === TARGET_JS) {
    message = message.slice(2);
  }
  let parsedMessage = null;
  try {
    parsedMessage = JSON.parse(message);
  } catch (err) {
    console.error('Can not parse message from backend, the raw message:', message);
    console.error(err);
  }

  if (parsedMessage !== null) {
    try {
      const action = parsedMessage[0];
      const target = nodeMap[parsedMessage[1][0]];
      const arg = parsedMessage[1][1];
      if (action === 'event') {
        handleEvent(target, arg);
      } else {
        console.error(`ERROR: Unknown action from backend ${action}, with arg: ${JSON.stringify(arg)}`);
      }
    } catch (err) {
      console.log(err.message);
    }
  }
});

function handleEvent(currentTarget: ElementImpl, event: any) {
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
        krakenSetStyle(id, styleKey, value);
        return true;
      },
      get(target: any, props: string | number | symbol, receiver) {
        let styleKey = toCamelCase(String(props));
        return this[styleKey];
      }
    });

    if (tagName != 'BODY') {
      krakenCreateElement(this.tagName, id, {}, []);
    }
  }

  addEventListener(eventName: string, eventListener: any) {
    super.addEventListener(eventName, eventListener);
    krakenAddEvent(this.id, eventName);
    this.events[eventName] = eventListener;
    nodeMap[this.id] = this;
  }

  removeEventListener(eventName: string, eventListener: any) {
    super.removeEventListener(eventName, eventListener);
    delete nodeMap[this.id];
    delete this.events[eventName];
    krakenRemoveEvent(this.id, eventName);
  }

  get nodeName() {
    return this.tagName.toUpperCase();
  }

  public setAttribute(name: string, value: string) {
    krakenSetProperty(this.id, name, value);
  }
}
