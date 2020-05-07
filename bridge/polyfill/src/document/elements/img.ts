import { Element } from '../element';

const imgBuiltInProperties = ['src', 'loading'];
const imgBuiltInEvents = ['load'];

export class ImgElement extends Element {
  constructor(tagName: string) {
    super(tagName, undefined, imgBuiltInEvents, imgBuiltInProperties);
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
