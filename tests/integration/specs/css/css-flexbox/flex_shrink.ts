describe('flexbox flex-shrink', () => {
  it('should work when flex-direction is row', async () => {
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      display: 'flex',
      flexDirection: 'row',
      width: '500px',
      height: '100px',
      marginBottom: '10px',
    });

    document.body.appendChild(container1);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      backgroundColor: '#999',
      width: '300px',
    });
    child1.appendChild(document.createTextNode('flex-shrink: 1'));
    container1.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      flexShrink: 2,
      backgroundColor: '#f40',
      width: '200px',
    });
    child2.appendChild(document.createTextNode('flex-shrink: 2'));
    container1.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      flexShrink: 1,
      backgroundColor: 'green',
      width: '200px',
    });
    child3.appendChild(document.createTextNode('flex-shrink: 1'));
    container1.appendChild(child3);

    await matchScreenshot();
  });

  it('should work when flex-direction is column', async () => {
    const container2 = document.createElement('div');
    setElementStyle(container2, {
      display: 'flex',
      flexDirection: 'column',
      width: '500px',
      height: '400px',
      marginBottom: '10px',
    });

    document.body.appendChild(container2);

    const child4 = document.createElement('div');
    setElementStyle(child4, {
      backgroundColor: '#999',
      height: '300px',
    });
    child4.appendChild(document.createTextNode('flex-shrink: 1'));
    container2.appendChild(child4);

    const child5 = document.createElement('div');
    setElementStyle(child5, {
      flexShrink: 2,
      backgroundColor: '#f40',
      height: '200px',
    });
    child5.appendChild(document.createTextNode('flex-shrink: 2'));
    container2.appendChild(child5);

    const child6 = document.createElement('div');
    setElementStyle(child6, {
      flexShrink: 1,
      backgroundColor: 'green',
      height: '200px',
    });
    child6.appendChild(document.createTextNode('flex-shrink: 1'));
    container2.appendChild(child6);

    await matchScreenshot();
  });
  it('not shrink no defined size elements', async () => {
    let element = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'display': 'flex',
        'position': 'relative',
        'flex-direction': 'column',
        'flex-shrink': 0,
        'align-content': 'flex-start',
        'margin': '0vw',
        padding: '0vw',
        'min-width': '0vw',
        height: '100vh'
      }
    }, [
      createElement('div', {
        style: {
          'box-sizing': 'border-box',
          'display': 'flex',
          'position': 'relative',
          'flex-direction': 'column',
          'flex-shrink': 0,
          'align-content': 'flex-start',
          'margin': '0vw',
          padding: '0vw',
          'min-width': '0vw',
          height: '29.3vw',
          'aligm-items': 'center',
          background: 'blue'
        }
      })
    ]);
    BODY.appendChild(element);
    await matchScreenshot();
  });
});
