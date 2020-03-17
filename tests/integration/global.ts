/**
 * This file will expose global functions for specs to use.
 *
 * - setStyle: Apply style object to a specfic DOM.
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

function sleep(second: number) {
  return new Promise(done => setTimeout(done, second * 1000));
}

function create(tag: string, style: object) {
  const el = document.createElement(tag);
  setStyle(el, style);
  return el;
}

async function matchScreenshot() {
  return await expectAsync(document.body.toBlob(1.0)).toMatchImageSnapshot();
}
