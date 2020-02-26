import { ElementImpl } from '../element';
import { method } from '../UIManager';

export class AudioImpl extends ElementImpl {
  constructor(tagName: string, id: number) {
    super(tagName, id);
  }

  play = () => {
    method(this.id, 'play', []);
  };

  pause = () => {
    method(this.id, 'pause', []);
  };

  fastSeek = (duration: number) => {
    method(this.id, 'fastSeek', [duration]);
  };
}
