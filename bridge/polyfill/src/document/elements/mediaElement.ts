import {Element} from '../element';
import {method} from "../ui-manager";

const _buildInEvents = [
  'abort', // not supported
  'canplay',
  'canplaythrough',
  'durationchange', // not supported
  'emptied', // not supported
  'ended', // not supported
  'error',
  'loadeddata', // not supported
  'loadedmetadata', // not supported
  'loadstart', // not supported
  'pause',
  'play',
  'playing', // not supported
  'progress', // not supported
  'ratechange', // not supported
  'seeked',
  'seeking',
  'stalled', // not supported
  'suspend', // not supported
  'timeupdate', // not supported
  'volumechange',
  'waiting' // not supported
];

export class MediaElement extends Element {
  constructor(tagName: string) {
    super(tagName, undefined, _buildInEvents);
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
