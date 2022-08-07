describe('FontSize', () => {
  it('should work with english', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontSize: '24px',
      },
      createText('These text should be 24px.')
    );
    append(BODY, p1);

    return snapshot();
  });

  it('should work with chinese', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontSize: '24px',
      },
      createText('24号字。')
    );
    append(BODY, p1);

    return snapshot();
  });

  it('should work with less than 12px', () => {
    const p1 = createElementWithStyle(
      'p',
      {
        fontSize: '12px',
      },
      createText('These lines should with 12px text size.')
    );
    const p2 = createElementWithStyle(
      'p',
      {
        fontSize: '5px',
      },
      createText('These lines should with 5px text size.')
    );

    append(BODY, p1);
    append(BODY, p2);

    return snapshot();
  });

  it('should work with percentage', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          fontSize: '50px',
          position: 'relative',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            backgroundColor: 'green',
            fontSize: '50%',
          }
        }, [
          createText('Kraken')
        ])
      ]
    );

    BODY.appendChild(div);
    await snapshot();
  });

  it('should work with percentage after element is attached', async (done) => {
    let div2;
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '200px',
          backgroundColor: 'yellow',
          fontSize: '50px',
          position: 'relative',
        },
      },
      [
        (div2 = createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            backgroundColor: 'green',
          }
        }, [
          createText('Kraken')
        ]))
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    requestAnimationFrame(async () => {
      div2.style.fontSize = '50%';
      await snapshot();
      done();
    });
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
        createText('inherited font-size')
      ])),
      (div2 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
          fontSize: '16px',
        }
      }, [
        createText('not inherited font-size')
      ]))
    ]);

    let container = createElement('div', {
      style: {
        fontSize: '18px'
      }
    });
    container.appendChild(div);
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.style.fontSize = '24px';
      await snapshot();
      done();
    });
  });

  it('should works with absolute-size keyword', async () => {
    for (const fontSize of ['xx-small', 'x-small', 'small', 'medium', 'large', 'x-large', 'xx-large', 'xxx-large']) {
      const div = createElement('div', {
        style: {
          fontSize: fontSize
        }
      }, [
        createText(fontSize)
      ]);
      BODY.appendChild(div);
    }

    await snapshot();
  });

  it('should works with relative-size keyword', async () => {
    for (const parentSize of ['16px', '32px', '48px']) {
      const div = createElement('div', {
        style: {
          fontSize: parentSize
        }
      }, [
        createElement('div', {
          style: {
            fontSize: 'smaller'
          }
        }, [createText(`${parentSize} smaller`)]),
        createElement('div', {}, [createText(`${parentSize}`)]),
        createElement('div', {
          style: {
            fontSize: 'larger'
          }
        }, [createText(`${parentSize} larger`)])
      ]);
      BODY.appendChild(div);
    }

    await snapshot();
  });
});
