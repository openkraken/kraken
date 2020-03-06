function setStyle(dom, object) {
  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

const container1 = document.createElement('div');
document.body.appendChild(container1);
setStyle(container1, {
  position: 'absolute',
  top: '100px',
  left: 0,
  padding: '20px',
  backgroundColor: '#999',
  transition: 'all 1s ease-out',
});
container1.appendChild(document.createTextNode('DIV 1'));

requestAnimationFrame(() => {
  setStyle(container1, {
    top: 0
  });
});
