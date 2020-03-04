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
  get src() {
    return this.getAttribute('src');
  }

  set autoplay(value: any) {
    this.setAttribute('autoplay', value);
  }
  get autoplay() {
    return this.getAttribute('autoplay');
  }

  set loop(value: any) {
    this.setAttribute('loop', value);
  }
  get loop() {
    return this.getAttribute('loop');
  }

  set poster(value: any) {
    this.setAttribute('poster', value);
  }
  get poster() {
    return this.getAttribute('poster');
  }
}
