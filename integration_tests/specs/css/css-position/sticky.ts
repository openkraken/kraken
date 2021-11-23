describe('Position sticky', () => {
  it('001', async () => {
    const sticky1 = document.createElement('div');
    sticky1.appendChild(document.createTextNode('sticky top 1'));
    setElementStyle(sticky1, {
      backgroundColor: '#f40',
      color: '#FFF',
      position: 'sticky',
      top: '0px',
      width: '414px',
      height: '50px',
    });

    const block1 = document.createElement('div');
    block1.appendChild(document.createTextNode('block1'));
    setElementStyle(block1, {
      backgroundColor: '#999',
      height: '200px',
    });

    const sticky2 = document.createElement('div');
    sticky2.appendChild(document.createTextNode('sticky top 2'));
    setElementStyle(sticky2, {
      backgroundColor: 'blue',
      color: '#FFF',
      position: 'sticky',
      top: '50px',
      width: '414px',
      height: '50px',
    });

    const block2 = document.createElement('div');
    block2.appendChild(document.createTextNode('block2'));
    setElementStyle(block2, {
      backgroundColor: '#999',
      height: '200px',
    });

    const sticky3 = document.createElement('div');
    sticky3.appendChild(document.createTextNode('sticky top 3'));
    setElementStyle(sticky3, {
      backgroundColor: 'green',
      color: '#FFF',
      position: 'sticky',
      top: '100px',
      width: '414px',
      height: '50px',
    });

    const block3 = document.createElement('div');
    block3.appendChild(document.createTextNode('block3'));
    setElementStyle(block3, {
      backgroundColor: '#999',
      height: '200px',
    });

    const sticky4 = document.createElement('div');
    sticky4.appendChild(document.createTextNode('sticky bottom'));
    setElementStyle(sticky4, {
      backgroundColor: 'purple',
      color: '#FFF',
      position: 'sticky',
      bottom: '50px',
      width: '414px',
      height: '50px',
    });

    const block4 = document.createElement('div');
    block4.appendChild(document.createTextNode('bottom block'));
    setElementStyle(block4, {
      backgroundColor: '#999',
      height: '800px',
    });

    document.body.appendChild(sticky1);
    document.body.appendChild(block1);
    document.body.appendChild(sticky2);
    document.body.appendChild(block2);
    document.body.appendChild(sticky3);
    document.body.appendChild(block3);
    document.body.appendChild(sticky4);
    document.body.appendChild(block4);

    await snapshot();
  });

  it('should work with scroll container padding change in flow layout', (done) => {
    let div2;
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'green',
          overflow: 'scroll'
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            position: 'sticky',
            top: '30px',
            left: '30px',
            height: '100px',
            width: '100px',
            backgroundColor: 'yellow',
          }
        })),
        (createElement('div', {
          style: {
            height: '300px',
            width: '500px',
            backgroundColor: 'blue',
          }
        }))
      ]
    );

    BODY.appendChild(div);

    requestAnimationFrame(async () => {
      div.style.paddingTop = '20px';
      div.style.paddingLeft = '20px';
      await snapshot();
      done();
    });
  });

  it('should work with scroll container padding change in flex layout of row direction', (done) => {
    let div2;
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          display: 'flex',
          backgroundColor: 'green',
          overflow: 'scroll'
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            position: 'sticky',
            top: '30px',
            left: '30px',
            height: '100px',
            width: '100px',
            flexShrink: 0,
            backgroundColor: 'yellow',
          }
        })),
        (createElement('div', {
          style: {
            height: '300px',
            width: '500px',
            flexShrink: 0,
            backgroundColor: 'blue',
          }
        }))
      ]
    );

    BODY.appendChild(div);

    requestAnimationFrame(async () => {
      div.style.paddingTop = '20px';
      div.style.paddingLeft = '20px';
      await snapshot();
      done();
    });
  });

  it('should work with scroll container padding change in flex layout of column direction', (done) => {
    let div2;
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          display: 'flex',
          flexDirection: 'column',
          backgroundColor: 'green',
          overflow: 'scroll'
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            position: 'sticky',
            top: '30px',
            left: '30px',
            height: '100px',
            width: '100px',
            flexShrink: 0,
            backgroundColor: 'yellow',
          }
        })),
        (createElement('div', {
          style: {
            height: '300px',
            width: '500px',
            flexShrink: 0,
            backgroundColor: 'blue',
          }
        }))
      ]
    );

    BODY.appendChild(div);

    requestAnimationFrame(async () => {
      div.style.paddingTop = '20px';
      div.style.paddingLeft = '20px';
      await snapshot();
      done();
    });
  });

  it('children size in scroll container changes', async (done) => {
    let prepadding;
    let filter;
    let sticky;
    let container;
    let coantents;
    let scroller;
    scroller = createElementWithStyle(
      'div',
      {
        'box-sizing': 'border-box',
        position: 'relative',
        width: '100px',
        height: '200px',
        overflow: 'scroll',
        background: 'yellow',
        border: '1px solid #fff',
      },
      [
        (contents = createElementWithStyle(
          'div',
          {
            'box-sizing': 'border-box',
            height: '200px',
            width: '100px',
          },
          [
            (prepadding = createElementWithStyle('div', {
              'box-sizing': 'border-box',
              height: '100px',
              width: '100px',
              'background-color': 'red',
            })),
            createElementWithStyle('div', {
              height: '100px',
              width: '100px',
              'background-color': 'blue',
            }, [
              (sticky = createElementWithStyle('div', {
                position: 'sticky',
                top: '50px',
                height: '50px',
                width: '100px',
                'background-color': 'green',
              })),
            ])

          ]
        )),
      ]
    );
    BODY.appendChild(scroller);

    await snapshot();

    requestAnimationFrame(async () => {
      prepadding.style.height = '10px';
      await snapshot();
      done();
    });
  });

  it('should work with overflow hidden element', async() => {
    const container1 = createElement('div', {
      style: {
        position: 'sticky',
        overflow: 'hidden',
        top: '100px',
        width: '100px',
        height: '50px',
        backgroundColor: '#666'
      }
    }, [
      createText('sticky')
    ]);

    document.body.appendChild(container1);
    
    const container2 = createElement('div', {
      style: {
        width: '100px',
        height: '200px',
        backgroundColor: 'yellow',
      }
    });

    document.body.appendChild(container2);

    await snapshot();
  });

  it('should work with sticky element in overflow hidden container', async() => {
    const container = createElement('div', {
      style: {
        overflow: 'hidden',
        width: '100px',
        height: '200px',
        marginTop: '50px',
        backgroundColor: 'green',
      }
    }, [
      createElement('div', {
        style: {
          position: 'sticky',
          top: '100px',
          height: '50px',
          backgroundColor: '#666'
        }
      }, [
        createText('sticky')
      ])
    ]);

    document.body.appendChild(container);

    await snapshot();
  });
});
