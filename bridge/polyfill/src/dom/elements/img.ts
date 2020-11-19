import { Element } from '../element';

const imgBuiltInProperties = ['src', 'loading'];
const imgBuiltInEvents = ['load', 'error'];

export class ImageElement extends Element {
  constructor() {
    super('img', undefined, imgBuiltInEvents, imgBuiltInProperties);
  }

  get width() {
    return Number(this.getAttribute('width'));
  }
  set width(value) {
    this.setAttribute('width', String(value));
  }

  get height() {
    return Number(this.getAttribute('height'));
  }
  set height(value) {
    this.setAttribute('height', String(value));
  }
}
