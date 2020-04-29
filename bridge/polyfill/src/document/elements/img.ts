import { Element } from '../element';

const imgBuildInProperties = ['src', 'loading'];
const imgBuildInEvents = ['load'];

export class ImgElement extends Element {
  constructor(tagName: string) {
    super(tagName, undefined, imgBuildInEvents, imgBuildInProperties);
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
