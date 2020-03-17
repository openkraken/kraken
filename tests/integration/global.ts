/**
 * This file will expose global functions for specs to use.
 *
 * - setStyle: Apply style object to a specfic DOM.
 * - setStyle: Apply attrs object to a specfic DOM.
 * - sleep: wait for several seconds.
 * - create: create element.
 * - matchScreenshot: match snapshot of body's image.
 */

function setStyle(dom: any, object: any) {
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

function create(tag: string, style: object) {
  const el = document.createElement(tag);
  setStyle(el, style);
  return el;
}

async function matchScreenshot(element: HTMLElement = document.body) {
  return await expectAsync(element.toBlob(1.0)).toMatchImageSnapshot();
}
