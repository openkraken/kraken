var div = document.createElement('div');
div.style.width = div.style.height = '300px';
div.style.backgroundColor = '#eee';

var canvas = document.createElement('canvas');
canvas.style.width = canvas.style.height = '200px';

// Async paint
requestAnimationFrame(() => {
  var context = canvas.getContext('2d');

  context.font = '24px AlibabaSans';
  context.fillStyle = 'green';
  context.fillRect(10, 10, 50, 50);
  context.clearRect(15, 15, 30, 30);
  context.strokeStyle = 'red';
  context.strokeRect(40, 40, 100, 100);
  context.fillStyle = 'blue';
  context.fillText('Hello World', 5.0, 5.0);
  context.strokeText('Hello World', 5.0, 25.0);
});


div.appendChild(canvas);
document.body.appendChild(div);
