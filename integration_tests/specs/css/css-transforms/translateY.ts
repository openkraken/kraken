describe('Transform translate3d', () => {
  it('001', async () => {
    document.body.appendChild(
      createElementWithStyle('div', {
        width: '100px',
        height: '100px',
        backgroundColor: 'red',
        transform: 'translateX(100px)',
      })
    );

    await snapshot();
  });

  it('should work with percentage', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            transform: 'translateY(50%)',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with negative percentage', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            transform: 'translateY(-50%)',
            backgroundColor: 'green',
          }
        })
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage of positioned element', async () => {
    let div1 = createElement(
      'div',
      {
        style: {
            backgroundColor: 'rgba(0, 0, 0, 0.6)',
            color: 'rgb(255, 255, 255)',
            padding: '8px 16px', 
            position: 'absolute',
            textAlign: 'center', 
            transform: 'translateY(50%)'
        },
      }, [
          createText('foo bar')
      ]);
    
    BODY.appendChild(div1);
    await snapshot();
  });
});
