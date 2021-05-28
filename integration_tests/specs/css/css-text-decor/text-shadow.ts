describe('Text TextDecoration', () => {
  const TEXT_SHADOW = [
    '3px 3px rgba(0,0,0,.3)',
    '4px 4px 4px rgba(0,0,0,.3)',
    '3px 3px 0 rgba(255,255,255,1),3px 3px 2px rgba(0,85,0,.8)',
  ];

  TEXT_SHADOW.forEach(value => {
    // Merged property.
    it(`should work with text-shadow=${value}`, () => {
      const cont = createElementWithStyle(
        'div',
        {
          margin: '10px',
          border: '1px solid #000',
          textShadow: `${value}`,
        },
        [
          createText(`These text should be text-shadow: ${value}.`),
          createText('文字阴影'),
        ]
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
        createText('inherited text-shadow')
      ])),
      (div2 = createElement('div', {
        style: {
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
          textShadow: '2px 2px 2px red',
        }
      }, [
        createText('not inherited text-shadow')
      ]))
    ]);

    let container = createElement('div', {
      style: {
        textShadow: '2px 2px 2px blue'
      }
    });
    container.appendChild(div);
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      container.style.textShadow = '2px 2px 2px yellow';
      await snapshot();
      done();
    });
  });
});
