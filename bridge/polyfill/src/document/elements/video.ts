import { MediaElement } from '../media-element';
import { getProperty } from '../ui-manager';

export class VideoElement extends MediaElement {
  constructor(tagName: string) {
    super(tagName);
  }

  get videoWidth() {
    return getProperty(this.targetId, 'videoWidth');
  }

  get videoHeight() {
    return getProperty(this.targetId, 'videoHeight');
  }
}
