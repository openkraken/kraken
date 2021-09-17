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

  it('scrollTop', async () => {
    const container = createSliverBasicCase();

    container.scrollBy(0, 200);
    expect(container.scrollTop).toEqual(200);

    container.scrollBy(0, -150);
    expect(container.scrollTop).toEqual(50);
  });

  it('scrollHeight', async () => {
    const container = createSliverBasicCase();

    container.scrollBy(0, 200);
    expect(container.scrollHeight).toEqual(100 * 99);
  });

  it('child contains Comment and Text', async () => {
    const container = createSliverBasicCase();
    const comment = document.createComment('foo');
    container.appendChild(comment);
    container.appendChild(document.createTextNode('hello'));

    // No error occurred, pass.
    await snapshot();
  });

  it('continuous scroll works', async () => {
    const container = createSliverBasicCase();

    container.scrollTo(0, 600);
    await snapshot();

    container.scrollTo(0, 200);
    await snapshot();
  });

  it('insertBefore with right order', async () => {
    var d = document.createElement('div');

    for (var i = 0; i < 100; i ++) {
      var e = document.createElement('div');
      e.style.background = 'red';
      e.style.width = e.style.height = '99px';
      e.appendChild(document.createTextNode(i + ''));
      d.insertBefore(e, d.firstChild);
    }

    d.style.display = 'sliver';
    d.style.width = '100px';
    d.style.height = '150px';

    document.body.appendChild(d);

    // Order from 99 -> 0
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
