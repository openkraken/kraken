import { ElementImpl } from '../element';
import { method } from '../UIManager';

export class AudioImpl extends ElementImpl {
  constructor(tagName: string) {
    super(tagName);
  }

  play = () => {
    method(this.nodeId, 'play', []);
  };

  pause = () => {
    method(this.nodeId, 'pause', []);
  };

  fastSeek = (duration: number) => {
    method(this.nodeId, 'fastSeek', [duration]);
  };
}
