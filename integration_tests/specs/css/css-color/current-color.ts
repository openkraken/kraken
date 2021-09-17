describe('Color currentColor', () => {

  it(`should supports currentColor value`, async () => {
    const text1 = document.createTextNode('DIV 1');
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      color: 'red',
      backgroundColor: 'green',
      border: '5px solid currentColor',
      boxShadow: '10px 5px 5px currentColor',
    });
    container1.appendChild(text1);

    await snapshot();
  });

  it(`should update currentColor value`, async () => {
    const text1 = document.createTextNode('DIV 1');
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
      position: 'absolute',
      top: 0,
      left: 0,
      padding: '20px',
      color: 'red',
      backgroundColor: 'green',
      border: '5px solid currentColor',
      boxShadow: '10px 5px 5px currentColor',
    });
    container1.appendChild(text1);
    
    requestAnimationFrame(function(){
      setElementStyle(container1, {
        color: 'black',
      });
    });

    await snapshot();
  });

});


