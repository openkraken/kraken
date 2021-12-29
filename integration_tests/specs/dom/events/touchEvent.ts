describe('TouchEvent', () => {
  it('should work with element touch start', (done) => {
    const div = document.createElement('div')
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);

    div.addEventListener('touchstart', e => {
      done();
    });

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
    });

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
    });
    simulateSwipe(0, 0, 100, 100, 0.5);
  });

  it('should work with element dispatch touch event', (done) => {
    let touchNum = 0;
    const div = document.createElement('div');
    div.style.backgroundColor = 'yellow';
    div.style.width = '100px';
    div.style.height = '100px';

    div.addEventListener('touchstart', () => touchNum++);

    document.body.appendChild(div)

    const div2 = document.createElement('div');
    div2.style.backgroundColor = 'red';
    div2.style.width = '50px';
    div2.style.height = '50px';
    div2.style.marginLeft = '100px';

    div2.addEventListener('touchstart', () => touchNum++);
    div.appendChild(div2);

    document.body.addEventListener('touchstart', () => {
      expect(touchNum).toBe(2);
      done();
    });

    simulateClick(120, 10);
  });

  it('should work with touches', async (done) => {
    const div = document.createElement('div');
    div.style.backgroundColor = 'blue';
    div.style.width = '30px';
    div.style.height = '30px';

    const func = async (e: TouchEvent) => {
      expect(e.touches.length).toBe(2);
      div.removeEventListener('touchend', func);
      await simulatePointUp(20, 20);
      done();
    };

    div.addEventListener('touchend', func);

    document.body.appendChild(div);

    await simulatePointDown(20, 20);
    
    await simulateClick(10, 10, 1);
  });

  it('should work with targetTouches when touching different elements', async (done) => {
    const div = document.createElement('div');
    div.style.backgroundColor = 'blue';
    div.style.width = '30px';
    div.style.height = '30px';

    const div2 = document.createElement('div');
    div2.style.backgroundColor = 'yellow';
    div2.style.width = '10px';
    div2.style.height = '10px';

    document.body.appendChild(div);

    div.appendChild(div2);

    const func = async (e: TouchEvent) => {
      expect(e.targetTouches.length).toBe(1);
      await simulatePointUp(20, 20);
      div2.removeEventListener('touchend', func);
      done();
    };

    div2.addEventListener('touchend', func);

    await simulatePointDown(20, 20);
    
    await simulateClick(5, 5 , 1);
  });

  it('touchend should work with changedTouches', async (done) => {
    const div = document.createElement('div');
    div.style.backgroundColor = 'blue';
    div.style.width = '30px';
    div.style.height = '30px';

    const func = (e: TouchEvent) => {
      expect(e.changedTouches.length).toBe(1);
      div.removeEventListener('touchend', func);
      done();
    };

    div.addEventListener('touchend', func)

    document.body.appendChild(div);
    
    await simulateClick(10, 10);
  });

  it('touchstart should work with changedTouches', async (done) => {
    const div = document.createElement('div');
    div.style.backgroundColor = 'blue';
    div.style.width = '30px';
    div.style.height = '30px';

    const func = (e: TouchEvent) => {
      expect(e.changedTouches.length).toBe(1);
      div.removeEventListener('touchstart', func);
      done();
    };

    div.addEventListener('touchstart', func)

    document.body.appendChild(div);
    
    await simulateClick(10, 10);
  });

  it('touchmove should work with changedTouches', async (done) => {
    const div = document.createElement('div');
    div.style.backgroundColor = 'blue';
    div.style.width = '30px';
    div.style.height = '30px';

    const func = (e: TouchEvent) => {
      expect(e.changedTouches.length).toBe(1);
      div.removeEventListener('touchmove', func);
      done();
    };

    div.addEventListener('touchmove', func)

    document.body.appendChild(div);
    
    await simulateSwipe(0, 0, 0, 100, 0.5);
  });
});
