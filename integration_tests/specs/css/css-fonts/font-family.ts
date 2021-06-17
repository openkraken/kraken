describe('FontFamily', () => {
  it('should works in english', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('These two lines should use the same font.')
    );
    const p2 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('These two lines should use the same font.')
    );
    append(BODY, p1);
    append(BODY, p2);

    return snapshot();
  });

  it('should works in chinese', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('字体文本测试。')
    );
    const p2 = createElementWithStyle(
      'p',
      {
        fontFamily: 'Songti SC',
        fontSize: '32px',
      },
      createText('字体文本测试。')
    );
    append(BODY, p1);
    append(BODY, p2);

    return snapshot();
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
          width: '250px',
          height: '100px',
          backgroundColor: 'lightgreen',
        }
      }, [
        createText('inherited font-family')
      ])),
      (div2 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
          fontFamily: 'arial',
        }
      }, [
        createText('not inherited font-family')
      ]))
    ]);

    let container = createElement('div', {
      style: {
        fontFamily: 'Songti SC'
      }
    });
    container.appendChild(div);
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.style.fontFamily = 'Tahoma';
      await snapshot();
      done();
    });
  });
});
