describe('Background linear-gradient', () => {
  it('001', async () => {
    var div1 = document.createElement('div');
    Object.assign(div1.style, {
      width: '200px',
      height: '100px',
      backgroundImage:
        'linear-gradient(to left, #333, #333 50%, #eee 75%, #333 75%)',
    });

    var div2 = document.createElement('div');
    Object.assign(div2.style, {
      width: '200px',
      height: '200px',
      backgroundImage:
        'conic-gradient(from 0.25turn at 50% 30%,red 20deg, orange 130deg, yellow 90deg, green 180deg, blue 270deg)',
    });

    var div3 = document.createElement('div');
    Object.assign(div3.style, {
      width: '200px',
      height: '200px',
      backgroundImage: 'radial-gradient(50%, red 0%, yellow 20%, blue 80%)',
    });

    var div4 = document.createElement('div');
    Object.assign(div4.style, {
      width: '200px',
      height: '100px',
      backgroundImage:
        'linear-gradient(135deg, red, red 10%, blue 75%, yellow 75%)',
    });

    document.body.appendChild(div1);
    document.body.appendChild(div2);
    document.body.appendChild(div3);
    document.body.appendChild(div4);

    await matchScreenshot();
  });
});
