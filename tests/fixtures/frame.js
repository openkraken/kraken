setTimeout(() => {
  console.log(222);

  var container = document.createElement('div');
  container.style.width = '300px';
  container.style.height = '300px';
  container.style.backgroundColor = 'red';

  var box = document.createElement('div');
  box.style.width = '150px';
  box.style.height = '150px';
  box.style.backgroundColor = 'green';


  container.appendChild(box);
  document.body.appendChild(container);

  // requestAnimationFrame(() => {
  //   console.log(1111);
  // });
}, 500);
