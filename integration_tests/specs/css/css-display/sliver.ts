describe('display sliver', () => {
  function createSliverBasicCase() {
    var d = document.createElement('div');

    for (var i = 0; i < 100; i ++) {
      var e = document.createElement('div');
      e.style.background = 'red';
      e.style.width = e.style.height = '99px';
      e.appendChild(document.createTextNode(i + ''));
      d.appendChild(e);
    }

    d.style.display = 'sliver';
    d.style.width = '100px';
    d.style.height = '150px';

    document.body.appendChild(d);

    return d;
  }

  it('basic', async () => {
    createSliverBasicCase();
    await snapshot();
  });

  it('sliver-direction', async () => {
    const container = createSliverBasicCase();
    (container.style as any).sliverDirection = 'column';

    await snapshot();
  });

  it('scroll works', async () => {
    const container = createSliverBasicCase();

    container.scrollBy(0, 200);
    await snapshot();

    container.scrollBy(0, -150);
    await snapshot();
  });

  it('should works with positioned element of no top and left', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'sliver',
          width: '200px',
          height: '200px',
        },
      }, [
        createElement('div', {
          style: {
            positive: 'relative',
            width: '200px',
            height: '100px',
          }
        }, [
          createElement('div', {
            style: {
              positive: 'absolute',
              width: '50px',
              height: '50px',
              backgroundColor: 'green',
            }
          }, [
            createText('1')
          ])
        ]),
        createElement('div', {
          style: {
            positive: 'relative',
            width: '200px',
            height: '100px',
          }
        }, [
          createElement('div', {
            style: {
              positive: 'absolute',
              width: '50px',
              height: '50px',
              backgroundColor: 'green',
            }
          }, [
            createText('2')
          ])
        ])
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

});
