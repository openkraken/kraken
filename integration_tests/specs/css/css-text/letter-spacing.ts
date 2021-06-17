describe('Text LetterSpacing', () => {
  const LETTER_SPACING = ['normal', '-5px', 0, '10px'];

  LETTER_SPACING.forEach(value => {
    it(`should work with ${value}`, () => {
      const cont = createElementWithStyle(
        'div',
        {
          margin: '10px',
          border: '1px solid #000',
          letterSpacing: value,
        },
        createText(`These text should be letter-spacing: ${value}.`)
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
        createText('inherited letter-spacing')
      ])),
      (div2 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
          letterSpacing: '1px',
        }
      }, [
        createText('not inherited letter-spacing')
      ]))
    ]);

    let container = createElement('div', {
      style: {
        letterSpacing: '2px'
      }
    });
    container.appendChild(div);
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.style.letterSpacing = '4px';
      await snapshot();
      done();
    });
  });
});
