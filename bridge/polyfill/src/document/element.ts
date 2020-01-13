import {NodeImpl, NodeType} from './node';
import {krakenCreateElement, krakenSetProperty} from './kraken';

export class ElementImpl extends NodeImpl {
  public readonly tagName: string;
  private _props: any = {};
  private events: string[] = [];
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
        this[toCamelCase(String(p))] = value;
        krakenSetProperty(id, '.style.' + String(p), value);
        return true;
      }
    });

    if (tagName != 'BODY') {
      krakenCreateElement(this.tagName, id, this._props, this.events);
    }
  }

  addEventListener(eventName: string, eventListener: any) {
    super.addEventListener(eventName, eventListener);
    this.events.push(eventName.toLowerCase());
  }

  get nodeName() {
    return this.tagName.toUpperCase();
  }

  public setAttribute(name: string, value: string) {
    krakenSetProperty(this.id, name, value);
  }
}
