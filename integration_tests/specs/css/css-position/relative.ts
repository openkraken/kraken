describe('Position relative', () => {
  it('001', async () => {
    const div1 = document.createElement('div');
    setElementStyle(div1, {
      width: '100px',
      height: '100px',
      backgroundColor: '#666',
      position: 'relative',
      top: '50px',
      left: '50px',
    });
    div1.appendChild(document.createTextNode('relative top & left'));
    document.body.appendChild(div1);

    const div2 = document.createElement('div');
    setElementStyle(div2, {
      width: '100px',
      height: '100px',
      backgroundColor: '#999',
      position: 'relative',
      bottom: '-50px',
      right: '-50px',
    });
    div2.appendChild(document.createTextNode('relative bottom & right'));
    document.body.appendChild(div2);

    await matchViewportSnapshot();
  });

  it('should be a green square below', async done => {
    let parent = createElementWithStyle('div', {
      width: '150px',
      height: '150px',
      backgroundColor: 'green',
    });
    let child = createElementWithStyle('div', {
      width: '150px',
      height: '150px',
      backgroundColor: 'white',
      position: 'relative',
    });
    append(parent, child);
    append(BODY, parent);
    await matchElementImageSnapshot(parent);

    requestAnimationFrame(async () => {
      child.style.left = '150px';
      await matchElementImageSnapshot(parent);
      done();
    });
  });

  it('relative text', async () => {
    var parent = document.createElement('div');
    Object.assign(parent.style, { position: 'absolute', width: '300px', height: '300px'});

    var son1 = document.createElement('div');
    var son2 = document.createElement('div');

    parent.appendChild(son1);
    parent.appendChild(son2);

    Object.assign(son1.style, {
      position: 'absolute',
      width: '100px',
      height: '100px',
      backgroundColor: 'red',
    });
    Object.assign(son2.style, {
      position: 'relative', // 需要定位, 效果应该跟 absolute 一样
    });
    son2.appendChild(document.createTextNode('HelloWorld'));


    document.body.appendChild(parent);

    await matchViewportSnapshot();
  });

  it('works with child remove' , async () => {
    let n1, n2;
    n1 = createElementWithStyle(
       'div',
       {
         display: 'flex',
         flexDirection: 'column',
         width: '300px',
         height: '300px',
         backgroundColor: 'gray',
       },
       [
        (n2 = createElementWithStyle(
          'div',
           {
             position: 'relative',
             width: '100px',
             height: '100px',
             backgroundColor: 'blue',
           },
        )),
        createElementWithStyle(
          'div',
           {
             position: 'relative',
             width: '100px',
             height: '100px',
             backgroundColor: 'green',
           },
        ),
       ]
     );
    BODY.appendChild(n1);
    n1.removeChild(n2);

    await matchViewportSnapshot();
  });

  it('should work with update position relative when comment node exists', async (done) => {
    let row1;
    let row2;
    let cont = createElement(
      'div',
      {
        style: {
        }
      },
      [
        (row1 = createElement('div', {
            style: {
              position: 'relative'
            }
        }, [
            createText('aaaaaa')
        ])),
        document.createComment(null),
        (row2 = createElement('div', {
            style: {
              position: 'relative'
            }
        }, [
            createText('bbbbbb')
        ])),
      ]
    );
    append(BODY, cont);

    await matchViewportSnapshot();

    requestAnimationFrame(async () => {
      row1.style.position = 'static';
      row1.style.position = 'relative';
      row2.style.position = 'static';
      row2.style.position = 'relative';
      await matchViewportSnapshot();
      done();
    });
  });
});
