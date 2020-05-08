import { Node, NodeType } from './node';
import { createTextNode, setProperty } from './ui-manager';

export class TextNode extends Node {
  public nodeName: string = '#text';
  public _data: string = '';

  constructor(data: string) {
    super(NodeType.TEXT_NODE);
    this._data = data;
    createTextNode(this.targetId, data);
  }

  public set data(data: string) {
    const value = String(data);
    this._data = value;
    setProperty(this.targetId, 'data', value);
  }

  public get data() {
    return this._data;
  }

  public set nodeValue(data: string) {
    this._data = String(data);
  }

  public get nodeValue() {
    return this._data;
  }

  public set textContent(data: string) {
    this._data = String(data);
  }

  public get textContent() {
    return this._data;
  }
}
