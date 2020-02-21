import { ElementImpl } from '../element';
import {
  method,
} from '../UIManager';

export class VideoImpl extends ElementImpl {
  constructor(tagName: string, id: number) {
    super(tagName, id);

    // compatible with W3C standard
    Object.defineProperty(this, 'muted', {
      configurable: false,
      enumerable: false,
      set(v) {
        this.setMuted(v);
      },
      get() {
        console.warn('video element\'s muted property is only settable and not readable');
        return null;
      }
    });
  }

  play = () => {
    method(this.id, 'play', []);
  };

  pause = () => {
    method(this.id, 'pause', []);
  };

  fastSeek = (duration: number) => {
    method(this.id, 'fastSeek', [String(duration)]);
  };

  // not w3c standard, but maybe useful.
  muted = (muted: boolean) => {
    method(this.id, 'muted', [muted]);
  }
}
