import { MediaElement } from '../media-element';
import { method } from '../ui-manager';

export class AudioElement extends MediaElement {
  constructor(tagName: string) {
    super(tagName);
  }

  play = () => {
    method(this.targetId, 'play');
  };

  pause = () => {
    method(this.targetId, 'pause');
  };

  fastSeek = (duration: number) => {
    method(this.targetId, 'fastSeek', [duration]);
  };
}
