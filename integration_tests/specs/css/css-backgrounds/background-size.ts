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
    await snapshot();
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
    await snapshot();
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
    await snapshot();
  });
  
  it('should works with auto of two values', async () => {
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
           backgroundSize: 'auto auto'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot();
  });

  it('should works with auto of first value', async () => {
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
           backgroundSize: 'auto 130px'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot();
  });

  it('should works with auto of second value', async () => {
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
           backgroundSize: '80px auto'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot();
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
    await snapshot();
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
    await snapshot();
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
    await snapshot();
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
    await snapshot();
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
    await snapshot();
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
    await snapshot();
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
    await snapshot();
  });

  it('should works with the height of background size bigger than the height of image container', async () => {
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
           backgroundSize: '180px',
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot();
  });

  it('should works with the width of background size bigger than the width of image container', async () => {
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
           backgroundSize: '280px 120px',
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot();
  });

  it('should works with background size bigger than image container', async () => {
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
           backgroundImage: 'url(assets/bg.jpg)',
           backgroundRepeat: 'no-repeat',
           backgroundSize: '250px',
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot();
  });
  
  it('should not work with negative value', async () => {
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
           backgroundSize: '170px -50px'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot();
  });

  it('should works with background-size value change', async (done) => {
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
           backgroundSize: '120px 30px',
           backgroundPosition: '10px 10px'
         },
       })),
     ]
    );
    append(BODY, div);
    await snapshot();

    requestAnimationFrame(async () => {
      div1.style.backgroundSize = '80px';
      div1.style.backgroundPosition = '40px 40px';
      await snapshot();
      done();
    });
  });
});
