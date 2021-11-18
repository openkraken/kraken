function jsx(tag, props, children) {
  if (typeof tag === 'string') {
    const element = document.createElement(tag);

    if(props) {
      Object.keys(props).forEach((key) => {
        if (!props[key]) {

        } else if (typeof props[key] === 'function') {
          element[key] = props[key];
        } else if (key === 'style') {
          Object.assign(element.style, props[key]);
        } else {
          element.setAttribute(key, props[key]);
        }
      });
    }


    if (!children) {

    } else {
      children = Array.isArray(children) ? children : [children];

      children.forEach((child) => {
        if (typeof child === 'string') {
          child = document.createTextNode(child);
        }
        child && element.appendChild(child);
      });
    }

    return element;
  } else if (typeof tag === 'function') {
    return tag({ ref, children, ...props });
  } else {
    console.error('Unknown tag:', tag);
  }
}

// const style = /*#__PURE__*/jsx("style", null, `.red { color: red; font-size: 20px; padding: 20px; margin: 20px;}`);
// const div = /*#__PURE__*/jsx("div", {
//   class: "red"
// }, 'It should red color');
// document.head.appendChild(style);
// document.body.appendChild(div);
// setTimeout(() => {
//   console.log('11');
//   document.head.removeChild(style);
// }, 2000);

global = this;
Object.defineProperty(global, 'BODY', {
 get() {
     return document.body;
 }
});
function setElementStyle(dom, object) {
 if (object == null)
     return;
 for (let key in object) {
     if (object.hasOwnProperty(key)) {
         dom.style[key] = object[key];
     }
 }
}
function setAttributes(dom, object) {
 for (const key in object) {
     if (object.hasOwnProperty(key)) {
         dom.setAttribute(key, object[key]);
     }
 }
}
// Avoid overwrited by jasmine.
const originalTimeout = global.setTimeout;
function sleep(second) {
 return new Promise(done => originalTimeout(done, second * 1000));
}
function setElementProps(el, props) {
 let keys = Object.keys(props);
 for (let key of keys) {
     if (key === 'style') {
         setElementStyle(el, props[key]);
     }
     else {
         el[key] = props[key];
     }
 }
}
function createElement(tag, props, child) {
 const el = document.createElement(tag);
 setElementProps(el, props);
 if (Array.isArray(child)) {
     child.forEach(c => el.appendChild(c));
 }
 else if (child) {
     el.appendChild(child);
 }
 return el;
}
function createElementWithStyle(tag, style, child) {
 const el = document.createElement(tag);
 setElementStyle(el, style);
 if (Array.isArray(child)) {
     child.forEach(c => el.appendChild(c));
 }
 else if (child) {
     el.appendChild(child);
 }
 return el;
}
function createViewElement(extraStyle, child) {
 return createElement('div', {
     style: Object.assign({ display: 'flex', position: 'relative', flexDirection: 'column', flexShrink: 0, alignContent: 'flex-start', border: '0 solid black', margin: 0, padding: 0, minWidth: 0 }, extraStyle),
 }, child);
}
function createText(content) {
 return document.createTextNode(content);
}
class Cubic {
 constructor(a, b, c, d) {
     this.a = a;
     this.b = b;
     this.c = c;
     this.d = d;
 }
 _evaluateCubic(a, b, m) {
     return 3 * a * (1 - m) * (1 - m) * m +
         3 * b * (1 - m) * m * m +
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
async function simulateClick(x, y, pointer = 0) {
 await simulatePointer([
     [x, y, PointerChange.down],
     [x, y, PointerChange.up]
 ], pointer);
}
// Simulate an mouse swipe action.
async function simulateSwipe(startX, startY, endX, endY, duration, pointer = 0) {
 let params = [[startX, startY, PointerChange.down]];
 let pointerMoveDelay = 0.001;
 let totalCount = duration / pointerMoveDelay;
 let diffXPerSecond = (endX - startX) / totalCount;
 let diffYPerSecond = (endY - startY) / totalCount;
 for (let i = 0; i < totalCount; i++) {
     let progress = i / totalCount;
     let diffX = diffXPerSecond * 100 * ease.transformInternal(progress);
     let diffY = diffYPerSecond * 100 * ease.transformInternal(progress);
     await sleep(pointerMoveDelay);
     params.push([startX + diffX, startY + diffY, PointerChange.move]);
 }
 params.push([endX, endY, PointerChange.up]);
 await simulatePointer(params, pointer);
}
// Simulate an point down action.
async function simulatePointDown(x, y, pointer = 0) {
 await simulatePointer([
     [x, y, PointerChange.down],
 ], pointer);
}
// Simulate an point up action.
async function simulatePoinrUp(x, y, pointer = 0) {
 await simulatePointer([
     [x, y, PointerChange.up],
 ], pointer);
}
function append(parent, child) {
 parent.appendChild(child);
}
async function snapshot(target, filename) {
 if (target && target.toBlob) {
     await expectAsync(target.toBlob(1.0)).toMatchSnapshot(filename);
 }
 else {
     if (typeof target == 'number') {
         await sleep(target);
     }
     await expectAsync(document.documentElement.toBlob(1.0)).toMatchSnapshot(filename);
 }
}
// Compatible to tests that use global variables.
Object.assign(global, {
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
 simulatePointDown,
 simulatePoinrUp,
});


// const wrapperStyle = {
//   border: '5px solid black',
//   position: 'relative',
//   width: '200px',
//   height: '150px',
//   margin: '10px',
// };

// const inlineBoxStyle = {
//   width: '50px',
//   height: '50px',
//   backgroundColor: 'blue',
//   display: 'inline-block',
// };

// const boxStyle = {
//   border: '10px solid cyan',
//   padding: '15px',
//   margin: '20px 0px',
//   backgroundColor: 'yellow',
// };

// const magentaDottedBorder = {
//   border: '5px solid magenta',
// };

// let wrapper = createElementWithStyle('div', wrapperStyle);
//     let canvas = createElementWithStyle('div', inlineBoxStyle);
//     append(wrapper, canvas);
//     let box = createElementWithStyle('div', {
//       ...boxStyle,
//       display: 'inline-flex',
//     });
//     append(wrapper, box);
//     append(BODY, wrapper);


// setTimeout(function(){
//   wrapper.toBlob(1.0).then(function(blob) { console.log(blob); });
// }, 2000);


// var name = 'grey';
// var rgba=[128, 128, 128, 1];
//   function rgbToHex(rgb) {
//     var hex = Number(rgb).toString(16);
//     if (hex.length < 2) {
//       hex = '0' + hex;
//     }
//     return hex;
//   }
//      let container = createElementWithStyle('div', {});
//       let p1 = createElementWithStyle('p', {
//         color: `rgb(${rgba[0]},${rgba[1]},${rgba[2]})`,
//       });
//       let p2 = createElementWithStyle('p', {
//         color: name,
//       });
//       let p3 = createElementWithStyle('p', {
//         color: `#${rgbToHex(rgba[0])}${rgbToHex(rgba[1])}${rgbToHex(rgba[2])}`,
//       });
//       let t1 = createText('helloworld');
//       let t2 = createText('helloworld');
//       let t3 = createText('helloworld');
//       append(p1, t1);
//       append(p2, t2);
//       append(p3, t3);
//       append(container, p1);
//       append(container, p2);
//       append(container, p3);
//       append(BODY, container);
// container.toBlob();


// const containerStyle = {
//   margin: '20px',
//   font: '40px',
//   border: '1px solid sliver',
//   width: '80px',
//   color: 'aqua',
//   backgroundColor: 'fuchsia',
// };
// const cStyle = {
//   color: 'orange',
//   backgroundColor: 'orange',
//   width: '40px',
//   marginLeft: '0',
//   borderLeft: '40px solid blue',
// };
// const bStyle = {
//   color: 'yellow',
// };
// let container = createElementWithStyle('div', containerStyle);
// let aText = createText(' A ');
// let bControl = createElementWithStyle('span', bStyle);
// let bText = createText('B');
// let cControl = createElementWithStyle('div', cStyle);
// let cText = createText('C');
// let aText2 = createText('  A');
// let bControl2 = createElementWithStyle('span', bStyle);
// let bText2 = createText('B');

// append(bControl, bText);
// append(bControl2, bText2);
// append(cControl, cText);
// append(container, aText);
// append(container, bControl);
// append(container, cControl);
// append(container, aText2);
// append(container, bControl2);
// append(BODY, container);

// container.toBlob();

const container = document.createElement('div');
    setElementStyle(container, {
      width: '400px',
      height: '400px',
      marginBottom: '20px',
      backgroundColor: '#999',
      position: 'relative',
    });
    document.body.appendChild(container);

    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
      position: 'absolute',
      top: '100px',
      left: '100px',
    });
    div1.appendChild(document.createTextNode('absolute to static'));
    container.appendChild(div1);

    const div2 = document.createElement('div');
    setElementStyle(div2, {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
      position: 'relative',
      top: '50px',
      left: '100px',
    });
    div2.appendChild(document.createTextNode('relative to static'));
    container.appendChild(div2);

    const div3 = document.createElement('div');
    setElementStyle(div3, {
      width: '100px',
      height: '100px',
      backgroundColor: 'green',
      position: 'fixed',
      top: '200px',
      left: '200px',
    });
    div3.appendChild(document.createTextNode('fixed to static'));
    container.appendChild(div3);

    const div4 = document.createElement('div');
    setElementStyle(div4, {
      width: '100px',
      height: '100px',
      backgroundColor: 'yellow',
      position: 'sticky',
      top: '50px',
    });
    div4.appendChild(document.createTextNode('sticky to static'));
    container.appendChild(div4);



    div1.style.position = 'static';
    div2.style.position = 'static';
    div3.style.position = 'static';
    div4.style.position = 'static';