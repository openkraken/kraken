/**
 * This file will expose global functions for specs to use.
 *
 * - setElementStyle: Apply style object to a specfic DOM.
 * - setElementProps: Apply attrs object to a specfic DOM.
 * - sleep: wait for several seconds.
 * - create: create element.
 * - matchScreenshot: match snapshot of body's image.
 */

let BODY = document.body;

function setElementStyle(dom: HTMLElement, object: any) {
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

function createElementWithStyle(tag: string, style: { [key: string]: string | number }, child?: Node | Array<Node>): any {
  const el = document.createElement(tag);
  setElementStyle(el, style);
  if (Array.isArray(child)) {
    child.forEach(c => el.appendChild(c));
  } else if (child) {
    el.appendChild(child);
  }
  return el;
}

type ElementProps = {
  [key: string]: any;
  style?: {
    [key: string]: any;
  }
};

function setElementProps(el: HTMLElement, props: ElementProps) {
  let keys = Object.keys(props);
  for (let key of keys) {
    if (key === 'style') {
      setElementStyle(el, props[key]);
    } else {
      el[key] = props[key];
    }
  }
}

function createElement(tag: string, props: ElementProps, child?: Node | Array<Node>) {
  const el = document.createElement(tag);
  setElementProps(el, props);
  if (Array.isArray(child)) {
    child.forEach(c => el.appendChild(c));
  } else if (child) {
    el.appendChild(child);
  }
  return el;
}

function createViewElement(extraStyle, child) {
  return createElement(
    'div',
    {
      style: {
        display: 'flex',
        position: 'relative',
        flexDirection: 'column',
        flexShrink: 0,
        alignContent: 'flex-start',
        border: '0 solid black',
        margin: 0,
        padding: 0,
        minWidth: 0,
        ...extraStyle,
      },
    },
    child
  );
}

function createText(content: string) {
  return document.createTextNode(content);
}

function append(parent: HTMLElement, child: Node) {
  parent.appendChild(child);
}

async function matchViewportSnapshot(wait: number = 0.0) {
  await sleep(wait);
  return await matchElementImageSnapshot(document.body);
}


async function matchElementImageSnapshot(element: HTMLElement) {
  return await expectAsync(element.toBlob(1.0)).toMatchImageSnapshot();
}
