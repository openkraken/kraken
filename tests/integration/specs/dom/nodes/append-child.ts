describe('Append child', () => {
  it('with orphan element', async () => {
    let n1;
    n1 = createElementWithStyle(
      'div',
      {
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      }
    );
    BODY.appendChild(n1);

    await matchScreenshot();
  });

  it('with orphan textNode', async () => {
    let n1;
    n1 = createText('foobar');
    BODY.appendChild(n1);

    await matchScreenshot();
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

    await matchScreenshot();
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

    await matchScreenshot();
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

    await matchScreenshot();
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

    await matchScreenshot();
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

    await matchScreenshot();
  });
});
