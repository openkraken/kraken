function setStyle(dom, object) {
  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

const container = document.createElement('div');
setStyle(container, {
  width: '400px',
  height: '400px',
  marginBottom: '20px',
  backgroundColor: '#999',
  position: 'relative',
});
document.body.appendChild(container);

const div1 = document.createElement('div');
setStyle(div1, {
  width: '100px',
  height: '100px',
  backgroundColor: 'red',
  top: '200px',
  left: '100px',
});
div1.appendChild(document.createTextNode('absolute to static'));
container.appendChild(div1);

const div2 = document.createElement('div');
setStyle(div2, {
  width: '100px',
  height: '100px',
  backgroundColor: 'blue',
  top: '50px',
  left: '100px',
});
div2.appendChild(document.createTextNode('relative to static'));
container.appendChild(div2);

const div3 = document.createElement('div');
setStyle(div3, {
  width: '100px',
  height: '100px',
  backgroundColor: 'green',
  top: '200px',
  left: '200px',
});
div3.appendChild(document.createTextNode('fixed to static'));
container.appendChild(div3);

const div4 = document.createElement('div');
setStyle(div4, {
  width: '100px',
  height: '100px',
  backgroundColor: 'yellow',
  top: '50px',
});
div4.appendChild(document.createTextNode('sticky to static'));
container.appendChild(div4);

requestAnimationFrame(() => {
  div1.style.position = 'absolute';
  div2.style.position = 'relative';
  div3.style.position = 'fixed';
  div4.style.position = 'sticky';
});

