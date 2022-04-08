import {Node} from "./node";

interface Document extends Node {
  /**
   * Returns the children.
   */
  readonly childNodes: number;
}
