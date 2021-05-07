//var text1 = document.createTextNode('Hello World!');
//var br = document.createElement('br');
//var text2 = document.createTextNode('你好，世界！');
//var p = document.createElement('p');
//p.style.textAlign = 'center';
//p.appendChild(text1);
//p.appendChild(br);
//p.appendChild(text2);
//
//document.body.appendChild(p);


//Object.defineProperty(global, 'BODY', {
// get() {
//   return document.body;
// }
//});

function setElementStyle(dom, object) {
 if (object == null) return;
 for (let key in object) {
   if (object.hasOwnProperty(key)) {
     dom.style[key] = object[key];
   }
 }
}


function setElementProps(el, props) {
 let keys = Object.keys(props);
 for (let key of keys) {
   if (key === 'style') {
     setElementStyle(el, props[key]);
   } else {
     el[key] = props[key];
   }
 }
}

function createText(content) {
 return document.createTextNode(content);
}

function createElement(tag, props, child) {
 const el = document.createElement(tag);
 setElementProps(el, props);
 if (Array.isArray(child)) {
   child.forEach(c => el.appendChild(c));
 } else if (child) {
   el.appendChild(child);
 }
 return el;
}

//
//let container = createElement('div',
//      {
//        style: {
//          width: '100px',
//          backgroundColor: '#999',
//        },
//      },
//      [
//        createText('12345'),
//        createElement('div', {
//          style: {
//            width: '50px',
//            height: '900px',
//            background: 'red',
//            top: '50px',
//          },
//        }),
//        createElement('div', {
//          style: {
//            width: '30px',
//            height: '30px',
//            background: 'green',
//            position: 'fixed',
//            top: '50px',
//          },
//        }),
//      ]
//    );
//
//    window.document.body.appendChild(container);
////window.addEventListener('scroll', function(x){ console.log('window', x);});
//    setTimeout(function(){
//      window.scroll(0, 200);
//    }, 10000);
//



 let div = document.createElement('div');
     div.style.border = '2px solid #000';
     div.style.height = '1000px';
     div.style.width = '50px';
     let text = document.createTextNode('This text should half visible');
     div.appendChild(text);
     document.body.appendChild(div);

// //    await snapshot();

//     requestAnimationFrame(() => {
//       window.scroll(0, 40);
// //      await snapshot();

//       console.log(window.scrollX)
//       console.log(window.scrollY)

//     });


//let container = createViewElement({
//  overflow: 'scroll',
//}, [
//  createElement('div', {
//    style: {
//      background: 'green',
//      height: '100px'
//    }
//  }, [createText('1234')]),
//  createElement('div', {
//    style: {
//      background: 'blue',
//      height: '200px'
//    }
//  }, [createText('4567')]),
//  createElement('div', {
//    style: {
//      background: 'red',
//      height: '800px'
//    }
//  })
//]);
//
//BODY.appendChild(container);


requestAnimationFrame(() => {
  document.documentElement.scrollLeft = 50;
  document.documentElement.scrollTop = 300;
});
