describe('TouchEvent', () => {
  it('should work with element touch start', (done) => {
    const div = document.createElement('div')
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);

    div.addEventListener('touchstart', e => {
      done();
    })

    simulateSwipe(0, 0, 100, 100, 0.5);
  });

  it('should work with element touch end', (done) => {
    const div = document.createElement('div')
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);

    div.addEventListener('touchend', e => {
      done();
    })

    simulateSwipe(0, 0, 100, 100, 0.5);
  });

  it('should work with element touch move', (done) => {
    const div = document.createElement('div')
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);

    div.addEventListener('touchmove', e => {
      done();
    })
    simulateSwipe(0, 0, 100, 100, 0.5);
  });

  it('should work with element dispatch touch event', (done) => {
    let startNum = 0;
    const div = document.createElement('div');
    div.style.backgroundColor = 'yellow';
    div.style.width = '100px';
    div.style.height = '100px';

    div.addEventListener('touchstart', ()=>startNum++)

    document.body.appendChild(div)

    const div2 = document.createElement('div');
    div2.style.backgroundColor = 'red';
    div2.style.width = '50px';
    div2.style.height = '50px';
    div2.style.marginLeft = '100px';

    div2.addEventListener('touchstart', ()=>startNum++)
    div.appendChild(div2)

    document.body.addEventListener('touchstart', ()=>{
      expect(startNum).toBe(2);
      done();
    })

    simulateClick(120, 10);
  });
});
  