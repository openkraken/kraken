import { Node } from './node';

interface DocumentFragment extends Node {
  new(): DocumentFragment;
}
