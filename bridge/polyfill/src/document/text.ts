import { NodeImpl, NodeType } from './node';
import { createTextNode, setProperty } from "./UIManager";

export class TextImpl extends NodeImpl {
  private _textContent: string = '';

  constructor(data: string, id: number) {
    super(NodeType.TEXT_NODE, id);
    this._textContent = data;
    createTextNode(id, NodeType.TEXT_NODE, data);
  }

  public get nodeName() {
    return '#text';
  }

  public get textContent() {
    return this._textContent;
  }

  public set textContent(data: string) {
    this._textContent = data;
    setProperty(this.id, 'data', data);
  }
}
