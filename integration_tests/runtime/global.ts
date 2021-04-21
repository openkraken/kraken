/**
 * This file will expose global functions for specs to use.
 *
 * - setElementStyle: Apply style object to a specfic DOM.
 * - setElementProps: Apply attrs object to a specfic DOM.
 * - sleep: wait for several seconds.
 * - create: create element.
 * - snapshot: match snapshot of body's image.
 */
const BODY = document.body;

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

class Cubic {
  /// The x coordinate of the first control point.
  ///
  /// The line through the point (0, 0) and the first control point is tangent
  /// to the curve at the point (0, 0).
  private readonly a: number;
  /// The y coordinate of the first control point.
  ///
  /// The line through the point (0, 0) and the first control point is tangent
  /// to the curve at the point (0, 0).
  private readonly b: number;
  /// The x coordinate of the second control point.
  ///
  /// The line through the point (1, 1) and the second control point is tangent
  /// to the curve at the point (1, 1).
  private readonly c: number;
  /// The y coordinate of the second control point.
  ///
  /// The line through the point (1, 1) and the second control point is tangent
  /// to the curve at the point (1, 1).
  private readonly d: number;

  constructor(a, b, c, d) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
  }

  _evaluateCubic(a, b, m) {
    return 3 * a * (1 - m) * (1 - m) * m +
      3 * b * (1 - m) *           m * m +
      m * m * m;
  }

  transformInternal(t) {
    let start = 0.0;
    let end = 1.0;
    while (true) {
      let midpoint = (start + end) / 2;
      let estimate = this._evaluateCubic(this.a, this.c, midpoint);
      if (Math.abs((t - estimate)) < 0.001)
        return this._evaluateCubic(this.b, this.d, midpoint);
      if (estimate < t)
        start = midpoint;
      else
        end = midpoint;
    }
  }
}

const ease = new Cubic(0.25, 0.1, 0.25, 1.0);

// Simulate an mouse click action
async function simulateClick(x: number, y: number) {
  await simulatePointer([
    [x, y, PointerChange.down],
    [x, y, PointerChange.up]
  ]);
}

// Simulate an mouse swipe action.
async function simulateSwipe(startX: number, startY: number, endX: number, endY: number, duration: number) {
  let params: [number, number, number][] = [[startX, startY, PointerChange.down]];
  let pointerMoveDelay = 0.001;
  let totalCount = duration / pointerMoveDelay;
  let diffXPerSecond = (endX - startX) / totalCount;
  let diffYPerSecond = (endY - startY) / totalCount;

  for (let i = 0; i < totalCount; i ++) {
    let progress = i / totalCount;
    let diffX = diffXPerSecond * 100 * ease.transformInternal(progress);
    let diffY = diffYPerSecond * 100 * ease.transformInternal(progress);
    await sleep(pointerMoveDelay);
    params.push([startX + diffX, startY + diffY, PointerChange.move])
  }

  params.push([endX, endY, PointerChange.up]);
  await simulatePointer(params);
}

function append(parent: HTMLElement, child: Node) {
  parent.appendChild(child);
}

async function snapshot(target?: any, filename ?: String) {
  if (target && target.toBlob) {
    await expectAsync(target.toBlob(1.0)).toMatchSnapshot(filename);
  } else {
    if (typeof target == 'number') {
      await sleep(target);
    }
    await expectAsync(document.body.toBlob(1.0)).toMatchSnapshot(filename);
  }
}

// Compatible to tests that use global variables.
Object.assign(global, {
  BODY,
  append,
  setAttributes,
  createElement,
  createElementWithStyle,
  createText,
  createViewElement,
  setElementStyle,
  setElementProps,
  simulateSwipe,
  simulateClick,
  sleep,
  snapshot,
});
