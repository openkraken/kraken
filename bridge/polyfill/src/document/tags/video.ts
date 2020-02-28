import { Element } from '../element';
import { method } from '../UIManager';

export class Video extends Element {
  constructor(tagName: string) {
    super(tagName);
  }

  play() {
    method(this.nodeId, 'play');
  }

  pause() {
    method(this.nodeId, 'pause');
  }
}
