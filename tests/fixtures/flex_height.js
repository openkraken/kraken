(() => {
  function setStyle(dom, object) {
    for (const key in object) {
      if (object.hasOwnProperty(key)) {
        dom.style[key] = object[key];
      }
    }
  }

  var container = document.createElement('div');
  document.body.appendChild(container);

  var flex1 = document.createElement('div');
  setStyle(flex1, {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'space-between',
    backgroundColor: '#f40',
    height: '100px'
  });

  var div1 = document.createElement('div');
  setStyle(div1, {
    backgroundColor: '#999',
    height: '50px'
  });
  var text1 = document.createTextNode('1111');
  div1.appendChild(text1);

  var div2 = document.createElement('div');
  setStyle(div2, {
    backgroundColor: '#999',
  });
  var text2 = document.createTextNode('2222');
  div2.appendChild(text2);


  var div3 = document.createElement('div');
  setStyle(div3, {
    display: 'flex',
    backgroundColor: '#999',
    height: '50px'
  });
  var text3 = document.createTextNode('3333');
  div3.appendChild(text3);

  var div4 = document.createElement('div');
  setStyle(div4, {
    display: 'flex',
    backgroundColor: '#999',
  });
  var text4 = document.createTextNode('4444');
  div4.appendChild(text4);


  flex1.appendChild(div1);
  flex1.appendChild(div2);
  flex1.appendChild(div3);
  flex1.appendChild(div4);

  var flex2 = document.createElement('div');
  setStyle(flex2, {
    display: 'flex',
    flexDirection: 'column',
    backgroundColor: 'blue',
    justifyContent: 'center',
    height: '100px'
  });

  var div5 = document.createElement('div');
  setStyle(div5, {
    backgroundColor: '#999',
  });
  var text5 = document.createTextNode('5555');
  div5.appendChild(text5);


  var div6 = document.createElement('div');
  setStyle(div6, {
    backgroundColor: '#999',
  });
  var text6 = document.createTextNode('6666');
  div6.appendChild(text6);

  flex2.appendChild(div5);
  flex2.appendChild(div6);

  container.appendChild(flex1);
  container.appendChild(flex2);
})();
