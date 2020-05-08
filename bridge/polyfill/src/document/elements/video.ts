import { MediaElement } from '../media-element';
import { method } from '../ui-manager';

export class VideoElement extends MediaElement {
  constructor(tagName: string) {
    super(tagName);
  }

  get videoHeight() {
    return method(this.targetId, 'videoHeight');
  }

  get videoWidth() {
    return method(this.targetId, 'videoWidth');
  }
}
