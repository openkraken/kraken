import {NodeImpl, NodeType} from './node';
import {krakenCreateTextNode} from "./kraken";

export class TextImpl extends NodeImpl {
  public textContent: string = '';
  constructor(text: string, id: number) {
    super(NodeType.TEXT_NODE, id);
    krakenCreateTextNode(id, NodeType.TEXT_NODE, text);
  }

  public get nodeName() {
    return '#text';
  }
}
