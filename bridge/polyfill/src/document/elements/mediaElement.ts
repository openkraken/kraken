import {Element} from '../element';
import {method} from "../ui-manager";

const mediaElementBuiltInEvents = [
  // 'abort', // not supported
  'canplay',
  'canplaythrough',
  // 'durationchange', // not supported
  // 'emptied', // not supported
  // 'ended', // not supported
  'error',
  // 'loadeddata', // not supported
  // 'loadedmetadata', // not supported
  // 'loadstart', // not supported
  'pause',
  'play',
  // 'playing', // not supported
  // 'progress', // not supported
  // 'ratechange', // not supported
  'seeked',
  'seeking',
  // 'stalled', // not supported
  // 'suspend', // not supported
  // 'timeupdate', // not supported
  'volumechange',
  // 'waiting' // not supported
];

const mediaElementBuiltInProperties = [
  'src',
  'autoplay',
  'loop',
  'poster'
];

export class MediaElement extends Element {
  constructor(tagName: string) {
    super(tagName, undefined, mediaElementBuiltInEvents, mediaElementBuiltInProperties);
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
