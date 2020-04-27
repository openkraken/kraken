/**
 * This file will expose global functions for specs to use.
 *
 * - setStyle: Apply style object to a specfic DOM.
 * - setStyle: Apply attrs object to a specfic DOM.
 * - sleep: wait for several seconds.
 * - create: create element.
 * - matchScreenshot: match snapshot of body's image.
 */

let BODY = document.body;

function setStyle(dom: HTMLElement, object: any) {
  if (object == null) return;
  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

function setAttributes(dom: any, object: any) {
  for (const key in object) {
    if (object.hasOwnProperty(key)) {
      dom.setAttribute(key, object[key]);
    }
  }
}

function sleep(second: number) {
  return new Promise(done => setTimeout(done, second * 1000));
}

function createElementWithStyle(tag: string, style: {[key: string]: string|number}, child?: Node | Array<Node>): any {
  const el = document.createElement(tag);
  setStyle(el, style);
  if (Array.isArray(child)) {
    child.forEach(c => el.appendChild(c));
  } else if (child) {
    el.appendChild(child);
  }
  return el;
}

function createText(content: string) {
  return document.createTextNode(content);
}

function append(parent: HTMLElement, child: Node) {
  parent.appendChild(child);
}

async function matchScreenshot() {
  return await matchElementImageSnapshot(document.body);
}


async function matchElementImageSnapshot(element: HTMLElement) {
  return await expectAsync(element.toBlob(1.0)).toMatchImageSnapshot();
}
