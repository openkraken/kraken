import { Node, NodeType } from './node';
import { createTextNode, setProperty } from './UIManager';

export class TextNode extends Node {
  public nodeName: string = '#text';
  public _data: string = '';

  constructor(data: string) {
    super(NodeType.TEXT_NODE);
    this._data = data;
    createTextNode(this.nodeId, data);
  }

  public set data(data: string) {
    this._data = String(data);
    setProperty(this.nodeId, 'data', data);
  }

  public get data() {
    return this._data;
  }

  public set nodeValue(data: string) {
    this.data = data;
  }

  public get nodeValue() {
    return this._data;
  }

  public set textContent(data: string) {
    this.data = data;
  }

  public get textContent() {
    return this._data;
  }
}
