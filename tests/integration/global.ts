/**
 * This file will expose global functions for specs to use.
 *
 * - setStyle: Apply style object to a specfic DOM.
 * - sleep: wait for several seconds.
 */

function setStyle(dom: any, object: any) {
  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

function sleep(second: number) {
  return new Promise(done => setTimeout(done, second * 1000));
}
