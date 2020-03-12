it('event', () => {
  return new Promise((resolve) => {
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
    container1.appendChild(document.createTextNode('DIV 1'));

    const container2 = document.createElement('div');
    setStyle(container2, {
      padding: '20px', height: '100px', backgroundColor: '#f40', margin: '40px'
    });
    container2.appendChild(document.createTextNode('DIV 2'));

    container1.appendChild(container2);

    document.body.addEventListener('click', () => {
      wrapper.appendChild(document.createTextNode('BODY clicked, '));
    });
    container1.addEventListener('click', () => {
      wrapper.appendChild(document.createTextNode('DIV 1 clicked, '));
    });
    container2.addEventListener('click', () => {
      wrapper.appendChild(document.createTextNode('DIV 2 clicked, '));
    });

    const wrapper = document.createElement('div');
    document.body.appendChild(wrapper);
    wrapper.appendChild(document.createTextNode('Click DIV 2: '));

    requestAnimationFrame(() => {
      container2.click();
      resolve();
    });
  });
});