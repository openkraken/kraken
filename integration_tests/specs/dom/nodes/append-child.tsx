describe('Append child', () => {
  it('with node is not type of node', () => {
    let container = document.createElement('div');
    expect(() => {
      // @ts-ignore
      container.appendChild({name: 1});
    }).toThrowError('Failed to execute \'appendChild\' on \'Node\': first arguments should be an Node type.');
    expect(() => {
      // @ts-ignore
      container.appendChild(new Event('1234'));
    }).toThrowError('Failed to execute \'appendChild\' on \'Node\': first arguments should be an Node type.');
  });
  it('with orphan element', async () => {
    const style = {
      width: '300px',
      height: '300px',
      backgroundColor: 'gray',
    };
    let n1 = <div style={style} />;
    BODY.appendChild(n1);

    await snapshot();
  });

  it('with orphan textNode', async () => {
    let n1;
    n1 = createText('foobar');
    BODY.appendChild(n1);

    await snapshot();
  });

  it('with element which has parent and connected', async () => {
    let n1;
    let n2;
    n1 = createElementWithStyle(
      'div',
      {
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      },
    );

    n2 = createElementWithStyle(
      'div',
      {
        width: '200px',
        height: '200px',
        backgroundColor: 'blue',
      },
    );

    BODY.appendChild(n1);
    BODY.appendChild(n2);
    n1.appendChild(n2);

    await snapshot();
  });

  it('with textNode which has parent and connected', async () => {
    let n1;
    let n2;
    n1 = createElementWithStyle(
      'div',
      {
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      },
    );

    n2 = createText('foobar');

    BODY.appendChild(n1);
    BODY.appendChild(n2);
    n1.appendChild(n2);

    await snapshot();
  });

  it('with element which has parent but not connected', async () => {
    let n1;
    let n2;
    n1 = createElementWithStyle(
      'div',
      {
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      },
      [
        (n2 = createElementWithStyle(
          'div',
          {
            width: '200px',
            height: '200px',
            backgroundColor: 'blue',
          },
        ))
      ]
    );
    BODY.appendChild(n2);

    await snapshot();
  });

  it('with textNode which has parent but not connected', async () => {
    let n1;
    let n2;
    n1 = createElementWithStyle(
      'div',
      {
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      },
      [
        (n2 = createText('foobar'))
      ]
    );
    BODY.appendChild(n2);

    await snapshot();
  });

  it('with connected and not connected children which has parent', async () => {
    let n1;
    let n2;
    let n3;
    let n4;

    n4 = createElementWithStyle(
      'div',
      {
        width: '375px',
        height: '375px',
        backgroundColor: 'gray',
      },
      [
        (n3 = createElementWithStyle(
          'div',
          {
            width: '300px',
            height: '300px',
            backgroundColor: 'blue',
          },
          [
            (n2 = createElementWithStyle(
              'div',
              {
                width: '200px',
                height: '200px',
                backgroundColor: 'yellow',
              },
              [
                (n1 = createElementWithStyle('div', {
                  width: '100px',
                  height: '100px',
                  backgroundColor: 'red',
                })),
              ]
            )),
          ]
        )),
      ]
    );
    BODY.appendChild(n2);
    BODY.appendChild(n4);

    await snapshot();
  });

  // https://developer.mozilla.org/en-US/docs/Web/API/Node/appendChild
  it('appendChild should return aChild', () => {
    const container = document.createElement('div');
    const child = document.createElement('span');

    expect(container.appendChild(child)).toEqual(child);
  });

  it('should work with elements created by new operator', () => {
    let img = new Image();
    let container = document.createElement('div');
    expect(img.ownerDocument).toBe(document);
    container.appendChild(img);
  });

  it('should work with removeChild then appendChild of the same node', async (done) => {
    var div = createElement('div', {
      style: {
        border: '1px solid green',
        backgroundColor: 'yellow',
        color: 'red',
        opacity: '0.5',
        width: '200px',
        height: '200px',
        overflowX: 'scroll',
        whiteSpace: 'nowrap',
        position: 'relative'
      } 
    }, [
      createText('aaaaaa bbbbbb cccccc dddddd eeeeee ffffff gggggg'),
      createElement('div', {
        style: {
          margin: '20px',
          width: '100px',
          height: '100px',
          backgroundColor: 'coral'
        }
      }, [
        createElement('div', {
          style: {
            position: 'absolute',
            left: '30px',
            top: '20px',
            width: '50px',
            height: '50px',
            backgroundColor: 'green',
            zIndex: 2
          }
        }),
        createElement('div', {
          style: {
            position: 'sticky',
            left: '50px',
            width: '50px',
            height: '50px',
            backgroundColor: 'blue',
            zIndex: 1
          }
        })
      ])
    ]);

    BODY.appendChild(div);
    div.scrollTo(1000, 0);

    await snapshot();

    requestAnimationFrame(() => {
      BODY.removeChild(div);
    });

    requestAnimationFrame(async () => {
      BODY.appendChild(div);
      await snapshot();
      div.scrollTo(1000, 0);
      await snapshot();
      done();
    });
  });
});
