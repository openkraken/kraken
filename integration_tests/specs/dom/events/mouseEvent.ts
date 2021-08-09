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

  it('should work width target when click', async (done) => {
    const div = document.createElement('div');
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';

    const span = document.createElement('span');

    span.appendChild(document.createTextNode('123'))

    const div2 = document.createElement('div');
    div2.style.backgroundColor = 'blue';
    div2.style.width = '50px';
    div2.style.height = '50px';

    div2.appendChild(span);
    div.appendChild(div2);
    document.body.appendChild(div);

    div.addEventListener('click', function handler(e) {
      expect(e.target).toBe(span);
      done();
    });
  
    await simulateClick(10.0, 10.0);
  });

  it('should work width currentTarget when click', async (done) => {
    const div = document.createElement('div');
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';

    const span = document.createElement('span');

    span.appendChild(document.createTextNode('123'))

    const div2 = document.createElement('div');
    div2.style.backgroundColor = 'blue';
    div2.style.width = '50px';
    div2.style.height = '50px';

    div2.appendChild(span);
    div.appendChild(div2);
    document.body.appendChild(div);

    div.addEventListener('click', function handler(e) {
      expect(e.currentTarget).toBe(div);
      done();
    });
  
    await simulateClick(10.0, 10.0);
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

  it('should work width document addEventListener', async (done) => {
    const div = document.createElement('div');
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);

    document.addEventListener('click', function handler(e) {
      done();
    });
  
    await simulateClick(10.0, 10.0);
  });

  it('should work width body addEventListener', async (done) => {
    const div = document.createElement('div');
    div.style.backgroundColor = 'red';
    div.style.width = '100px';
    div.style.height = '100px';
    document.body.appendChild(div);

    document.body.addEventListener('click', function handler(e) {
      done();
    });
  
    await simulateClick(10.0, 10.0);
  });
  
  it('should not crash when cloneNode img element', async (done) => {
    const img = document.createElement('img');
    img.style.width = '100px';
    img.style.height = '100px';
    img.src = "https://img.alicdn.com/imgextra/i4/O1CN01vfjZK31uFiEAKOl8g_!!6000000006008-2-tps-200-200.png";
    document.body.appendChild(img);
    const img2 = img.cloneNode(true);
    document.body.appendChild(img2);

    img2.addEventListener('click',()=>{
        done();
    })

    img2.click();
  })

  it('should work with dblclick', async (done) => {
    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';
    div.style.backgroundColor = 'red';
    document.body.appendChild(div);
    div.addEventListener('dblclick', (e)=>{
      done();
    })
    await simulateClick(10.0, 10.0);
    await sleep(0.1);
    await simulateClick(10.0, 10.0);
  });
});
