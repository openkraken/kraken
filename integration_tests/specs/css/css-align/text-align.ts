describe('Align text-align', () => {
  it('001', async () => {
    var container = document.createElement('div');

    var div1 = document.createElement('div');
    Object.assign(div1.style, {
      textAlign: 'center',
      backgroundColor: '#f40',
    });
    div1.appendChild(document.createTextNode('flow layout text-align center'));
    container.appendChild(div1);

    var div2 = document.createElement('div');
    Object.assign(div2.style, {
      boxSizing: 'border-box',
      display: 'flex',
      flexDirection: 'column',
      alignContent: 'flex-start',
      flexShrink: 0,
      position: 'relative',
      textAlign: 'center',
      backgroundColor: 'green',
    });
    div2.appendChild(document.createTextNode('flex layout text-align center'));
    container.appendChild(div2);

    var div3 = document.createElement('div');
    Object.assign(div3.style, {
      textAlign: 'left',
      backgroundColor: 'red',
      lineHeight: '30px',
    });
    div3.appendChild(document.createTextNode('flow layout line-height 30'));
    container.appendChild(div3);

    var div4 = document.createElement('div');
    Object.assign(div4.style, {
      textAlign: 'right',
      backgroundColor: 'yellow',
      lineHeight: '40px',
    });
    div4.appendChild(document.createTextNode('flow layout line-height 40'));
    container.appendChild(div4);

    document.body.appendChild(container);

    await snapshot();
  });

  it('works with inheritance', async (done) => {
    let div1;
    let div2;
    let div = createElement('div', {
      style: {
        position: 'relative',
        width: '300px',
        height: '200px',
        backgroundColor: 'grey',
      }
    }, [
      (div1 = createElement('div', {
        style: {
          display: 'inline-block',
          width: '250px',
          height: '100px',
          backgroundColor: 'lightgreen',
        }
      }, [
        createText('inherited text-align')
      ])),
      (div2 = createElement('div', {
        style: {
          display: 'inline-block',
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
          textAlign: 'left',
        }
      }, [
        createText('not inherited text-align')
      ]))
    ]);

    let container = createElement('div', {
      style: {
        textAlign: 'center'
      }
    });
    container.appendChild(div);
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.style.textAlign = 'right';
      await snapshot();
      done();
    });
  });

  it('works only with inline and inline-block', async () => {
    let div1;
    let div2;
    let div = createElement('div', {
      style: {
        position: 'relative',
        width: '300px',
        height: '200px',
        backgroundColor: 'grey',
        textAlign: 'center'
      }
    }, [
      (div1 = createElement('div', {
        style: {
          display: 'inline-block',
          width: '250px',
          height: '50px',
          backgroundColor: 'lightgreen',
        }
      }, [
        createText('display inline-block')
      ])),
      (createElement('div', {
        style: {
          display: 'inline-flex',
          width: '250px',
          height: '50px',
          backgroundColor: 'pink',
        }
      }, [
        createText('display inline-flex')
      ])),
      (div2 = createElement('div', {
        style: {
          width: '250px',
          height: '50px',
          backgroundColor: 'lightblue',
          fontFamily: 'arial',
        }
      }, [
        createText('display block')
      ])),
      (createElement('div', {
        style: {
          display: 'flex',
          width: '250px',
          height: '50px',
          backgroundColor: 'coral',
          fontFamily: 'arial',
        }
      }, [
        createText('display flex')
      ]))
    ]);

    BODY.appendChild(div);

    await snapshot();
  });
});
