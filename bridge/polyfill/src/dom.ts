const head = document.createElement('head');
document.documentElement.appendChild(head);
Object.defineProperty(document, 'head', {
  value: head,
  enumerable: true,
  writable: false,
  configurable: false
});

const body = document.createElement('body');
document.documentElement.appendChild(body);
Object.defineProperty(document, 'body', {
  value: body,
  enumerable: true,
  writable: false,
  configurable: false
});
