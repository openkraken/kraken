describe('flexbox flex-basis', () => {
  it('should work with auto', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      display: 'flex',
      flexDirection: 'row',
      width: '300px',
      height: '100px',
      backgroundColor: '#999',
      justifyContent: 'center',
    });

    document.body.appendChild(container1);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      backgroundColor: '#333',
    });
    child1.appendChild(document.createTextNode('Item One'));
    container1.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      backgroundColor: '#f40',
    });
    child2.appendChild(document.createTextNode('Item Two'));
    container1.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      backgroundColor: 'green',
    });
    child3.appendChild(document.createTextNode('Item Three'));
    container1.appendChild(child3);

    await snapshot();
  });

  it('should work with width', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      display: 'flex',
      flexDirection: 'row',
      width: '300px',
      height: '100px',
      backgroundColor: '#999',
      justifyContent: 'center',
    });

    document.body.appendChild(container1);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      backgroundColor: '#333',
      flexBasis: '100px',
    });
    child1.appendChild(document.createTextNode('Item One'));
    container1.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      backgroundColor: '#f40',
    });
    child2.appendChild(document.createTextNode('Item Two'));
    container1.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      backgroundColor: 'green',
    });
    child3.appendChild(document.createTextNode('Item Three'));
    container1.appendChild(child3);

    await snapshot();
  });
  
  it('should work with px', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          height: '100px',
          width: '200px',
          display: 'flex',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              width: '50px',
              'max-width': '60px',
              display: 'inline-block',
              flexBasis: '0',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'pink',
              width: '50px',
              flexBasis: '40px',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              width: '50px',
              flexBasis: '60px',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
  
  it('should work with percentage', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          background: 'blue',
          height: '100px',
          width: '200px',
          display: 'flex',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'yellow',
              width: '50px',
              'max-width': '60px',
              display: 'inline-block',
              flexBasis: '0%',
              'box-sizing': 'border-box',
            },
          },
          [createText(`one`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'pink',
              width: '50px',
              flexBasis: '20%',
            },
          },
          [createText(`two`)]
        ),
        createElement(
          'span',
          {
            style: {
              background: 'lightblue',
              width: '50px',
              flexBasis: '30%',
            },
          },
          [createText(`three`)]
        ),
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });
});
