describe('Text WordSpacing', () => {
  const WORD_SPACING = ['normal', '-5px', 0, '10px'];

  WORD_SPACING.forEach(value => {
    it(`should work with ${value}`, () => {
      const cont = createElementWithStyle(
        'div',
        {
          margin: '10px',
          border: '1px solid #000',
          wordSpacing: value,
        },
        createText(`These text should be word-spacing: ${value}.`)
      );
      append(BODY, cont);

      return snapshot(cont);
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
        createText('inherited word-spacing')
      ])),
      (div2 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
          wordSpacing: '2px',
        }
      }, [
        createText('not inherited word-spacing')
      ]))
    ]);

    let container = createElement('div', {
      style: {
        wordSpacing: '10px'
      }
    });
    container.appendChild(div);
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.style.wordSpacing = '20px';
      await snapshot();
      done();
    });
  });
});
