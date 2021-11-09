
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

// var text1 = document.createTextNode('Hello World!');
// var br = document.createElement('br');
// var text2 = document.createTextNode('你好，世界！');
// var p = document.createElement('p');
// p.setAttribute('class', 'foo');
// p.style.textAlign = 'center';
// p.style.border = '1em solid red';
// p.style.padding = '1em';
// p.style.margin = '2rem';
// p.style.backgroundColor = '#eee';
// p.appendChild(text1);
// p.appendChild(br);
// p.appendChild(text2);

// document.body.appendChild(p);


// setTimeout(() => {
//   var s = document.createElement('style');
//   s.appendChild(document.createTextNode(`.foo {color: red}`));
//   document.body.appendChild(s);
// }, 5000);


// setTimeout(() => { p.style.color = 'red'; }, 1000);

// const div = document.createElement('div');
// div.style.position = 'relative';
// div.style.width = '100px';
// div.style.height = '100px';

// const div2 = document.createElement('div');
// div2.style.position = 'absolute';
// div2.style.zIndex = '2';
// div2.style.width = '100%';
// div2.style.height = '100%';
// div2.style.background = 'blue';
// div2.addEventListener('click', ()=>{
//   console.log('blue')
// })

// const div3 = document.createElement('div');
// div3.style.position = 'absolute';
// div3.style.zIndex = '1';
// div3.style.width = '100%';
// div3.style.height = '100%';
// div3.style.background = 'red';
// div3.addEventListener('click', ()=>{
//   console.log('red')
// })

// document.body.appendChild(div);
// div.appendChild(div2);
// div.appendChild(div3);

// const div = document.createElement('div');
// div.style.width = '100px';
// div.style.height = '100px';
// div.style.backgroundColor = 'yellow';
// div.setAttribute('id', '123');
// document.body.appendChild(div)

// const div2 = div.cloneNode(true);

// const container1 = document.createElement('div');
// document.body.appendChild(container1);
// setElementStyle(container1, {
//   position: 'absolute',
//   top: 0,
//   left: 0,
//   padding: '20px',
//   backgroundColor: '#999',
//   transitionProperty: 'transform',
//   transitionDuration: '1s',
//   transitionTimingFunction: 'ease',
// });
// container1.appendChild(document.createTextNode('DIV 1'));

// setTimeout(async () => {
//   setElementStyle(container1, {
//     transform: 'rotateZ(0.6turn)',
//   });
// }, 5000);


// const container1 = document.createElement('div');
//     document.body.appendChild(container1);
//     setElementStyle(container1, {
//       position: 'absolute',
//       padding: '30px',
//       transition: 'all 5s linear',
//     });
//     container1.appendChild(document.createTextNode('DIV'));

//     setTimeout(() => {
//       setElementStyle(container1, {
//         backgroundColor: 'red',
//       });
//     }, 3000);

//
//const container1 = document.createElement('div');
//    document.body.appendChild(container1);
//    setElementStyle(container1, {
//      position: 'absolute',
//      top: 0,
//      left: 0,
//      padding: '20px',
//      backgroundColor: '#999',
//      transitionProperty: 'transform',
//      transitionDuration: '1s',
//      transitionTimingFunction: 'ease',
//    });
//    container1.appendChild(document.createTextNode('DIV 1'));
//
//    requestAnimationFrame(async () => {
//
//      setElementStyle(container1, {
//        transform: 'scaleX(2)',
//      });
//
//    });
//
//
//
//const container1 = document.createElement('div');
//    document.body.appendChild(container1);
//    setElementStyle(container1, {
//      position: 'absolute',
//      top: '100px',
//      left: 0,
//      padding: '20px',
//      backgroundColor: '#999',
//      transition: 'all 5s linear',
//    });
//    container1.appendChild(document.createTextNode('DIV'));
//
//
//const button = document.createElement('div');
//button.appendChild(document.createTextNode('To Right'));
//
//button.onclick = function(){
//  setElementStyle(container1, {
//      left: '200px',
//    });
//};
//
//
//    document.body.appendChild(button);
//
//const button1 = document.createElement('div');
//button1.appendChild(document.createTextNode('To Left'));
//
//button1.onclick = function() {
//  setElementStyle(container1, {
//      left: '0',
//    });
//};
//
//    document.body.appendChild(button1);

//
//    const container1 = document.createElement('div');
//    document.body.appendChild(container1);
//    setElementStyle(container1, {
//      position: 'absolute',
//      top: '100px',
//      left: 0,
//      padding: '20px',
//      backgroundColor: '#999',
//    });
//    container1.appendChild(document.createTextNode('DIV'));
//    await snapshot();
//
//    requestAnimationFrame(() => {
//      setElementStyle(container1, {
//        transform: 'translate3d(200px, 0, 0)',
//        transition: 'all 1s linear',
//      });
//
//      setTimeout(async () => {
//        await snapshot();
//      }, 500);
//
//      // Wait for animation finished.
//      setTimeout(async () => {
//        await snapshot();
//        done();
//      }, 1100);
//    });

//it('style added', async () => {
   // const style = jsx("style", {
   //   children: `.red { color: red; }`
   // });

   // const div = jsx("div", {
   //   class: "red",
   //   children: 'It should red color'
   // });

   // document.head.appendChild(style);
   // document.body.appendChild(div);
//    ;
//    await snapshot(null, "snapshots/css/cssom/class-selector.ts");
//  });
//  it('style removed', async () => {
//    const style = jsx("style", {
//      children: `.red { color: red; }`
//    });
//
//    const div = jsx("div", {
//      class: "red",
//      children: 'It should black color'
//    });
//
//    document.head.appendChild(style);
//    document.body.appendChild(div);
//    document.head.removeChild(style);
//    ;
//    await snapshot(null, "snapshots/css/cssom/class-selector.ts");
//  });
//  it('style removed later', async done => {
//    const style = jsx("style", {
//      children: `.red { color: red; }`
//    });
//
//    const div = jsx("div", {
//      class: "red",
//      children: 'It should black color'
//    });
//
//    document.head.appendChild(style);
//    document.body.appendChild(div);
//    requestAnimationFrame(async () => {
//      document.head.removeChild(style);
//      ;
//      await snapshot(null, "snapshots/css/cssom/class-selector.ts");
//      done();
//    });
//  });
//  it('two style added', async () => {
//    const style1 = jsx("style", {
//      children: `.red { color: red; }`
//    });
//
//    const style2 = jsx("style", {
//      children: `.red { font-size: 20px; }`
//    });
//
//    const div = jsx("div", {
//      class: "red",
//      children: 'It should red color and 20px'
//    });
//
//    document.head.appendChild(style1);
//    document.body.appendChild(div);
//    document.head.appendChild(style2);
//    ;
//    await snapshot(null, "snapshots/css/cssom/class-selector.ts");
//  });
//  it('one style removed', async () => {
//    const style1 = jsx("style", {
//      children: `.red { color: red; }`
//    });
//
//    const style2 = jsx("style", {
//      children: `.red { font-size: 20px; }`
//    });
//
//    const div = jsx("div", {
//      class: "red",
//      children: 'It should black color and 20px'
//    });
//
//    document.head.appendChild(style1);
//    document.body.appendChild(div);
//    document.head.appendChild(style2);
//    document.head.removeChild(style1);
//    ;
//    await snapshot(null, "snapshots/css/cssom/class-selector.ts");
//  });




// const style1 = /*#__PURE__*/jsx("style", null, `.red { color: red; }`);
// const style2 = /*#__PURE__*/jsx("style", null, `.red { font-size: 20px; }`);
// const div = /*#__PURE__*/jsx("div", {
//   class: "red"
// }, 'It should black color and 20px');
// document.head.appendChild(style1);
// document.head.appendChild(style2);
// document.body.appendChild(div);

// div.setAttribute('style', 'color: yellow;');


// // setTimeout(function(){
//  div.style.removeProperty('color');
// // }, 3000);

// //div.style.color = null;
// //   document.head.removeChild(style1);


let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'none',
          width: '200px',
          height: '100px',
          backgroundColor: 'green',
        },
      },
      [
        createElement('span', {
          style: {
            backgroundColor: 'yellow',
          }
        }, [
          createText('none to block'),
        ])
      ]
    );

    BODY.appendChild(div);

    setTimeout( () => {
       div.style.display = 'block';
       console.log('sss');
    }, 5000);
