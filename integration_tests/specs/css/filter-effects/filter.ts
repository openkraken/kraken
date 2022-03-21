describe('CSS Filter Effects', () => {
  it('grayscale', async () => {
    let div = document.createElement('div');
    setElementStyle(div, {
      width: '360px',
      height: '200px',
      background: 'left top / contain repeat url(/assets/rabbit.png)'
    });
    document.body.appendChild(div);
    div.style.filter = 'grayscale(1)';
    await sleep(0.5);
    await snapshot();
  });

  it('blur', async () => {
    let div = document.createElement('div');
    setElementStyle(div, {
      width: '360px',
      height: '200px',
      background: 'left top / contain repeat url(/assets/rabbit.png)'
    });
    document.body.appendChild(div);
    div.style.filter = 'blur(2px)';
    await sleep(0.5);
    await snapshot();
  });
});
