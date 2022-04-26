import {Node} from "../node";

export interface NodeList {
  readonly length: int64;
  item(index: number): Node;
  readonly [index: number]: Node;
  new(): void;
}
