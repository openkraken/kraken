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
});
