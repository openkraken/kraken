let html = document.createElement('html');
document.appendChild(html);

let head = document.createElement('head');
document.documentElement.appendChild(head);

let body = document.createElement('body');
document.documentElement.appendChild(body);

// @ts-ignore
class SVGElement extends Element {
  constructor() {
    super();
  }
}

Object.defineProperty(window, 'SVGElement', {
  value: SVGElement
});
