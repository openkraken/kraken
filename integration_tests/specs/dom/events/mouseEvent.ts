describe('MouseEvent', () => {
  it('should exist MouseEvent global object', () => {
    expect(MouseEvent).toBeDefined();
    expect(() => {
      new MouseEvent('click');
    }).not.toThrow();
  });

  it('should work with element click', (done) => {
    const div = document.createElement('div')
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);
    
    div.addEventListener('click', e=> {
      done();
    })
    div.click();
  });

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

  it('should new MouseEvent', () => {
    let mouseEvent = new MouseEvent('mouseEvent');
    expect(mouseEvent.type).toEqual('mouseEvent');
  });

  it('should work width clientX', async (done) => {
    const div = document.createElement('div')
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);
    
    div.addEventListener('click', e=> {
      expect(e.clientX).toBe(1.0);
      done();
    })
    await simulateClick(1.0, 1.0);
  });

  it('should work width clientY', async (done) => {
    const div = document.createElement('div')
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);
    
    div.addEventListener('click', e=> {
      expect(e.clientY).toBe(10.0);
      done();
    })
    await simulateClick(1.0, 10.0);
  });

  it('should work width offsetX', async (done) => {
    const div = document.createElement('div')
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);
    
    div.addEventListener('click', e=> {
      expect(e.offsetX).toBe(1.0);
      done();
    })
    await simulateClick(1.0, 1.0);
  });

  it('should work width offsetY', async (done) => {
    const div = document.createElement('div')
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);
    
    div.addEventListener('click', e=> {
      expect(e.offsetY).toBe(10.0);
      done();
    })
    await simulateClick(1.0, 10.0);
  });

  it('should work width target', async (done) => {
    const div = document.createElement('div');
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';

    const span = document.createElement('span');

    span.appendChild(document.createTextNode('123'))

    const p = document.createElement('p');
    p.style.backgroundColor = 'blue';
    p.style.width = '50px';
    p.style.height = '50px';

    p.appendChild(span);
    div.appendChild(p);
    document.body.appendChild(div);

    div.addEventListener('click', function handler(e) {
      expect(e.target).toBe(span);
      done();
    });
  
    span.click();
  });

  it('should work width currentTarget', async (done) => {
    const div = document.createElement('div');
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';

    const span = document.createElement('span');

    span.appendChild(document.createTextNode('123'))

    const p = document.createElement('p');
    p.style.backgroundColor = 'blue';
    p.style.width = '50px';
    p.style.height = '50px';

    p.appendChild(span);
    div.appendChild(p);
    document.body.appendChild(div);

    div.addEventListener('click', function handler(e) {
        expect(e.currentTarget).toBe(div);
        done();
    });
  
    span.click();
  });
});
