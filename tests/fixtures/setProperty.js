function setStyle(dom, object) {
  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

var div = document.createElement('div');
document.body.appendChild(div);

div.style.width = '100px';
div.style.height = '100px';
div.style.backgroundColor = 'red';

(() => {
  let container = document.createElement('div');
  setStyle(container, {
    display: 'flex',
    backgroundColor: '#252423',
  });

  for (let i = 0; i < 5; i++) {
    let dotEl = document.createElement('div');
    setStyle(dotEl, {
      display: 'inline-block',
      marginLeft: '5px',
      width: '40px',
      height: '40px',
      'borderRadius': '20px',
      'backgroundColor': '#FF4B4B'
    });
    container.appendChild(dotEl);
  }

  document.body.appendChild(container);
})();
