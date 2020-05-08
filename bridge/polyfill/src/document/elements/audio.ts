import { MediaElement } from '../media-element';
import { method } from '../ui-manager';

export class AudioElement extends MediaElement {
  constructor(tagName: string) {
    super(tagName);
  }

  play = () => {
    method(this.nodeId, 'play');
  };

  pause = () => {
    method(this.nodeId, 'pause');
  };

  fastSeek = (duration: number) => {
    method(this.nodeId, 'fastSeek', [duration]);
  };
}
