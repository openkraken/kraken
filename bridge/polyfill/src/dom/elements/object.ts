import {Element} from '../element';


/**
 *  Definition: https://html.spec.whatwg.org/multipage/iframe-embed-object.html#the-object-element
 */
const objectElementBuiltInProperties = ['type', 'data'];

export class ObjectElement extends Element {
  constructor() {
    super('object', undefined, undefined, objectElementBuiltInProperties);
  }

  get currentData() {
    return this.getAttribute('data');
  }

  get currentType() {
    return this.getAttribute('type');
  }

}
