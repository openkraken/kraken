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

  fastSeek = (duration: number) => {
    method(this.nodeId, 'fastSeek', [duration]);
  };

  set src(value: string) {
    this.setAttribute('src', value);
  }

  set autoplay(value: any) {
    this.setAttribute('autoplay', value);
  }

  set loop(value: any) {
    this.setAttribute('loop', value);
  }

  set poster(value: any) {
    this.setAttribute('poster', value);
  }
}
