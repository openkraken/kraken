describe('Insert before', () => {
  it('with node is not a type of node', () => {
    let container = document.createElement('div');
    let node = document.createElement('div');
    container.appendChild(node);

    expect(() => {
      // @ts-ignore
      container.insertBefore(new Event('1234'), null);
    }).toThrowError('Failed to execute \'insertBefore\' on \'Node\': parameter 1 is not of type \'Node\'');
  });
  it('with node is a child of another parent', () => {
    let container = document.createElement('div');
    let node = document.createElement('div');
    container.appendChild(node);
    let otherContainer = document.createElement('div');
    otherContainer.insertBefore(node, null);
    expect(node.parentNode === otherContainer).toBe(true);
    expect(container.childNodes.length).toBe(0);
  });
  it('basic', async () => {
    var div = document.createElement('div');
    var span = document.createElement('span');
    var textNode = document.createTextNode('Hello');
    span.appendChild(textNode);
    div.appendChild(span);
    document.body.appendChild(div);

    var insertText = document.createTextNode('World');
    var insertSpan = document.createElement('span');
    insertSpan.appendChild(insertText);
    div.insertBefore(insertSpan, span);

    await snapshot();
  });

  it('referenceNode is null', async () => {
    let n1;
    n1 = createElementWithStyle(
      'div',
      {
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      }
    );
    BODY.insertBefore(n1, null);

    await snapshot();
  });

  it('with orphan element', async () => {
    let n1;
    let n2;
    n1 = createElementWithStyle(
      'div',
      {
        width: '300px',
        height: '300px',
        backgroundColor: 'gray',
      }
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
    BODY.insertBefore(n2, n1);

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
    n1.insertBefore(n2, null);

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
    BODY.appendChild(n1);
    BODY.insertBefore(n2, n1);

    await snapshot();
  });

  it('insert before position fixed element', async () => {
    let child1 = createElement('div', {
      style: {
        position: 'fixed',
        top: '100px',
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    let child2;
    const container = createElement('div', {
      style: {
        width: '200px',
        height: '200px',
        background: 'yellow'
      }
    }, [
      (child2 = createElement('div', {
        style: {
          position: 'fixed',
          width: '100px',
          height: '100px',
          background: 'green'
        }
      }))
    ]);

    document.body.appendChild(container);

    container.insertBefore(child1, child2);

    await snapshot();
  });

  it('insert before position absolute element', async () => {
    let child1 = createElement('div', {
      style: {
        width: '100px',
        height: '100px',
        background: 'red'
      }
    });
    let child2;
    const container = createElement('div', {
      style: {
        width: '200px',
        height: '200px',
        background: 'yellow'
      }
    }, [
      (child2 = createElement('div', {
        style: {
          position: 'absolute',
          width: '100px',
          height: '100px',
          background: 'green'
        }
      }))
    ]);

    document.body.appendChild(container);

    container.insertBefore(child1, child2);

    await snapshot();
  });

  it('insert before referenceNode is comment', async () => {
    var container = document.createElement('div');
    document.body.appendChild(container);
    container.style.display = 'flex';
    container.style.flexDirection = 'column';

    var ref;
    container.appendChild(document.createTextNode('text1'));
    container.appendChild(ref = document.createComment('comment1'));
    container.appendChild(document.createTextNode('text2'));

    container.insertBefore(document.createTextNode('This line should between text1 and text2'), ref);

    await snapshot();
  });
});
