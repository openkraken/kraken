import { Element } from '../element';

const builtInProperties = [
  'value', 
  'accept', 
  'autocomplete', 
  'autofocus', 
  'checked',
  'disabled',
  'min',
  'max',
  'minlength',
  'maxlength',
  'size',
  'multiple',
  'name',
  'step',
  'pattern',
  'required',
  'readonly',
  'placeholder',
  'type',
];
const builtInEvents = ['input', 'change'];

export class InputElement extends Element {
  constructor() {
    super('input', undefined, builtInEvents, builtInProperties);
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