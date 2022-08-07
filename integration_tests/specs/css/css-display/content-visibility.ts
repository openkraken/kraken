describe('Content Visibility', () => {
  it('should visible', async () => {
    let container;
    container = createViewElement(
      {
        width: '200px',
        height: '500px',
        flexShrink: 1,
        border: '2px solid #000',
      },
      [
        createViewElement(
          {
            height: '20px',
          },
          []
        ),
        createViewElement(
          {
            flex: 1,
            width: '200px',
            contentVisibility: 'visible',
            background: 'red'
          },
          [
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
          ]
        ),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('should hidden', async () => {
    let container;
    let block;
    container = createViewElement(
      {
        width: '200px',
        height: '500px',
        flexShrink: 1,
        border: '2px solid #000',
      },
      [
        createViewElement(
          {
            height: '20px',
          },
          []
        ),
        createViewElement(
          {
            flex: 1,
            width: '200px',
            contentVisibility: 'hidden',
            background: 'red'
          },
          [
            block = createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
            createElement('div', {}, [createText('123456')]),
          ]
        ),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('should auto visible', async () => {
    var container1 = document.createElement('div');

    setElementStyle(container1, {
      contentVisibility: 'hidden',
      backgroundColor: 'red',
      width: '200px',
      height: '200px',
    });

    document.body.appendChild(container1);

    setElementStyle(container1, {
      contentVisibility: 'auto',
    });


    await snapshot();
  });

  it('should auto hidden', async () => {
    var container1 = document.createElement('div');

    setElementStyle(container1, {
      contentVisibility: 'hidden',
      backgroundColor: 'red',
      width: '200px',
      height: '200px',
    });

    document.body.appendChild(container1);

    setElementStyle(container1, {
      position: 'absolute',
      top: '-1000px',
    });

    let text = document.createTextNode('helloworld');
    container1.appendChild(text);

    // Should be empty blob
    await snapshot(container1);
  });

  it('should work with null', async () => {
    var container1 = document.createElement('div');

    setElementStyle(container1, {
      contentVisibility: 'hidden',
      backgroundColor: 'red',
      width: '200px',
      height: '200px',
    });

    document.body.appendChild(container1);

    setElementStyle(container1, {
      position: 'absolute',
      top: '-1000px',
      contentVisibility: null
    });


    // Should be visible.
    await snapshot(container1);
  });
});
