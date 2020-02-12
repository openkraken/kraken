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
  padding: '20px', backgroundColor: '#999', margin: '40px'
});

const container2 = document.createElement('div');
container2.appendChild(document.createTextNode('event test'));
setStyle(container2, {
  padding: '20px', height: '100px', backgroundColor: '#f40', margin: '40px'
});

container1.appendChild(container2);

document.body.addEventListener('click', () => {
  console.log('body clicked');
});
container1.addEventListener('click', () => {
  console.log('container1 clicked');
});
container2.addEventListener('click', () => {
  console.log('container2 clicked');
});
