import {MediaElement} from './mediaElement';
import {method} from '../ui-manager';

export class VideoElement extends MediaElement {
  constructor(tagName: string) {
    super(tagName);
  }

  get videoHeight() {
    return method(this.nodeId, 'videoHeight');
  }

  get videoWidth() {
    return method(this.nodeId, 'videoWidth');
  }
}
