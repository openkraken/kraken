it('overflow', () => {
  var container = document.createElement('div');

  var div1 = document.createElement('div');
  Object.assign(div1.style, {
    "overflowX": "scroll",
    "width": "100px"
  });
  div1.appendChild(document.createTextNode('overflow_X_auto_test'));
  container.appendChild(div1);

  var div2 = document.createElement('div');
  Object.assign(div2.style, {
    "overflowX": "visible",
    "width": "100px"
  });
  div2.appendChild(document.createTextNode('overflow_X_visible_test'));
  container.appendChild(div2);


  var div3 = document.createElement('div');
  Object.assign(div3.style, {
    "overflowX": "hidden",
    "width": "100px"
  });
  div3.appendChild(document.createTextNode('overflow_X_hidden_test'));
  container.appendChild(div3);

  document.body.appendChild(container);
});