let head = document.createElement('head');
document.documentElement.appendChild(head);
Object.defineProperty(document, 'head', {
  set(value: HTMLHeadElement) {
    if (value == null || value.tagName != 'HEAD') {
      throw TypeError(`Failed to set the 'head' property on 'Document': The new body element must be a 'head' element.`)
    }
    document.documentElement.replaceChild(value, head);
    head = value;
  },
  get() {
    return head;
  },
  enumerable: true,
  configurable: false
});

let body = document.createElement('body');
document.documentElement.appendChild(body);
Object.defineProperty(document, 'body', {
  set(value: HTMLBodyElement) {
    if (value == null || value.tagName != 'BODY') {
      throw TypeError(`Failed to set the 'body' property on 'Document': The new body element must be a 'BODY' element.`)
    }
    document.documentElement.replaceChild(value, body);
    body = value;
  },
  get() {
    return body;
  },
  enumerable: true,
  configurable: false
});

// @ts-ignore
class SVGElement extends Element {
  constructor() {
    super();
  }
}

Object.defineProperty(window, 'SVGElement', {
  value: SVGElement
});
