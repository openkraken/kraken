function setStyle(dom, object) {
  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

const sticky1 = document.createElement('div');
sticky1.appendChild(document.createTextNode('sticky 1'));
setStyle(sticky1, {
  backgroundColor: '#f40',
  color: '#FFF',
  position: 'sticky',
  top: '0px',
  width: '414px',
  height: '50px',
});

const block1 = document.createElement('div');
block1.appendChild(document.createTextNode('block1'));
setStyle(block1, {
  backgroundColor: '#999', height: '200px'
});

const sticky2 = document.createElement('div');
sticky2.appendChild(document.createTextNode('sticky 2'));
setStyle(sticky2, {
  backgroundColor: 'blue',
  color: '#FFF',
  position: 'sticky',
  top: '50px',
  width: '414px',
  height: '50px',
});

const block2 = document.createElement('div');
block2.appendChild(document.createTextNode('block2'));
setStyle(block2, {
  backgroundColor: '#999', height: '200px'
});

const sticky3 = document.createElement('div');
sticky3.appendChild(document.createTextNode('sticky 3'));
setStyle(sticky3, {
  backgroundColor: 'green',
  color: '#FFF',
  position: 'sticky',
  top: '100px',
  width: '414px',
  height: '50px',
});

const block3 = document.createElement('div');
block3.appendChild(document.createTextNode('bottom block'));
setStyle(block3, {
  backgroundColor: '#999', height: '800px'
});

document.body.appendChild(sticky1);
document.body.appendChild(block1);
document.body.appendChild(sticky2);
document.body.appendChild(block2);
document.body.appendChild(sticky3);
document.body.appendChild(block3);

