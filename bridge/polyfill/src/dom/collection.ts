import { Node } from './node';

export class HTMLAllCollection {
  private _referenceArray: Array<Node>;

  constructor(referenceArray?: Array<Node>) {
    this._referenceArray = referenceArray || [];
  }

  public item(index: number) {
    return this._referenceArray[index];
  }

  public add(node: Node, before?: Node) {
    if (before) {
      const ref = this._referenceArray.indexOf(before);
      this._referenceArray.splice(ref, 0, node);
    } else {
      this._referenceArray.push(node);
    }
  }

  public remove(index: number) {
    this._referenceArray.splice(index, 1);
  }

  get length() {
    return this._referenceArray.length;
  }
}
