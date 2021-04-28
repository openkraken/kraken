describe('MouseEvent', () => {
  it('should exist CustomEvent global object', () => {
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
});
  
  