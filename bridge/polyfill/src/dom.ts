let head = document.createElement('head');
document.documentElement.appendChild(head);
Object.defineProperty(document, 'head', {
  value: head,
  writable: false,
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

window.postMessage = (message, origin) => {
  window.dispatchEvent(new MessageEvent('message', {
    data: message,
    origin,
  }));
}


