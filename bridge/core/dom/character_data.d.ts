import {Node} from "./node";

export interface CharacterData extends Node {
  readonly data: string;
  readonly length: int64;
  new(): void;
}
