function setStyle(dom, object) {
  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

const div = document.createElement('div');
setStyle(div, {
  width: '100px',
  height: '100px',
  backgroundColor: '#666',
  border: '2px solid #f40',
});

document.body.appendChild(div);

requestAnimationFrame(() => {
  div.style.border = '4px solid blue';
});
