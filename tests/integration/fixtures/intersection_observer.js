it('intersectionObserver', () => {
  return new Promise((resolve) => {
    var div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';

    div.addEventListener('disappear', () => {
      div.style.backgroundColor = 'green';
      div.style.bottom = '0';
      resolve();
    });

    document.body.appendChild(div);

    requestAnimationFrame(() => {
      div.style.position = 'absolute';
      div.style.bottom = '-600px';
    });
  });
});
