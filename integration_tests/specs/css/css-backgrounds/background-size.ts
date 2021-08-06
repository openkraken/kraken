describe('Background-size', () => {
  it('should works with contain', async () => {
    let div1;
    let div = createElement(
     'div',
     {
       style: {},
     },
     [
       (div1 = createElement('div', {
         style: {
           height: '150px',
           width: '200px',
           backgroundColor: '#999',
           backgroundImage: 'url(assets/100x100-green.png)',
           backgroundRepeat: 'no-repeat',
           backgroundSize: 'contain'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });

  it('should works with cover', async () => {
    let div1;
    let div = createElement(
     'div',
     {
       style: {},
     },
     [
       (div1 = createElement('div', {
         style: {
           height: '150px',
           width: '200px',
           backgroundColor: '#999',
           backgroundImage: 'url(assets/100x100-green.png)',
           backgroundRepeat: 'no-repeat',
           backgroundSize: 'cover'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });

  it('should works with auto', async () => {
    let div1;
    let div = createElement(
     'div',
     {
       style: {},
     },
     [
       (div1 = createElement('div', {
         style: {
           height: '150px',
           width: '200px',
           backgroundColor: '#999',
           backgroundImage: 'url(assets/100x100-green.png)',
           backgroundRepeat: 'no-repeat',
           backgroundSize: 'auto'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });
  
  it('should works with one value of length', async () => {
    let div1;
    let div = createElement(
     'div',
     {
       style: {},
     },
     [
       (div1 = createElement('div', {
         style: {
           height: '150px',
           width: '200px',
           backgroundColor: '#999',
           backgroundImage: 'url(assets/100x100-green.png)',
           backgroundRepeat: 'no-repeat',
           backgroundSize: '120px'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });

  it('should works with two values of length', async () => {
    let div1;
    let div = createElement(
     'div',
     {
       style: {},
     },
     [
       (div1 = createElement('div', {
         style: {
           height: '150px',
           width: '200px',
           backgroundColor: '#999',
           backgroundImage: 'url(assets/100x100-green.png)',
           backgroundRepeat: 'no-repeat',
           backgroundSize: '120px 60px'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });

  it('should works with one value of percentage', async () => {
    let div1;
    let div = createElement(
     'div',
     {
       style: {},
     },
     [
       (div1 = createElement('div', {
         style: {
           height: '150px',
           backgroundColor: '#999',
           backgroundImage: 'url(assets/100x100-green.png)',
           backgroundRepeat: 'no-repeat',
           backgroundSize: '20%'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });

  it('should works with two values of percentage', async () => {
    let div1;
    let div = createElement(
     'div',
     {
       style: {},
     },
     [
       (div1 = createElement('div', {
         style: {
           height: '150px',
           backgroundColor: '#999',
           backgroundImage: 'url(assets/100x100-green.png)',
           backgroundRepeat: 'no-repeat',
           backgroundSize: '70% 30%'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });

  it('should works with two values of mixed percentage and length', async () => {
    let div1;
    let div = createElement(
     'div',
     {
       style: {},
     },
     [
       (div1 = createElement('div', {
         style: {
           height: '150px',
           width: '200px',
           backgroundColor: '#999',
           backgroundImage: 'url(assets/100x100-green.png)',
           backgroundRepeat: 'no-repeat',
           backgroundSize: '70% 110px'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });

  it('should works with length value and background-repeat of repeat', async () => {
    let div1;
    let div = createElement(
     'div',
     {
       style: {},
     },
     [
       (div1 = createElement('div', {
         style: {
           height: '150px',
           width: '200px',
           backgroundColor: '#999',
           backgroundImage: 'url(assets/test-bl.png)',
           backgroundRepeat: 'repeat',
           backgroundSize: '120px'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });

  it('should works with percentage value and background-repeat of repeat', async () => {
    let div1;
    let div = createElement(
     'div',
     {
       style: {},
     },
     [
       (div1 = createElement('div', {
         style: {
           height: '150px',
           width: '200px',
           backgroundColor: '#999',
           backgroundImage: 'url(assets/test-bl.png)',
           backgroundRepeat: 'repeat',
           backgroundSize: '40%'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot(0.1);
  });
});
