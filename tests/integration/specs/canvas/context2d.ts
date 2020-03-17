describe('Canvas context 2d', () => {
  it('should work with font and rect', async () => {
    var div = document.createElement('div');
    div.style.width = div.style.height = '300px';
    div.style.backgroundColor = '#eee';

    var canvas = document.createElement('canvas');
    canvas.style.width = canvas.style.height = '200px';
    div.appendChild(canvas);

    var context = canvas.getContext('2d');

    if (!context) {
      throw new Error('canvas context is null');
    }
    context.font = '24px AlibabaSans';
    context.fillStyle = 'green';
    context.fillRect(10, 10, 50, 50);
    context.clearRect(15, 15, 30, 30);
    context.strokeStyle = 'red';
    context.strokeRect(40, 40, 100, 100);
    context.fillStyle = 'blue';
    context.fillText('Hello World', 5.0, 5.0);
    context.strokeText('Hello World', 5.0, 25.0);

    document.body.appendChild(div);

    await expectAsync(canvas.toBlob(1.0)).toMatchImageSnapshot();
  });
});
