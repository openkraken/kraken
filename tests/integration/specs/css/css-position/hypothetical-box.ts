/*auto generated*/
describe('hypothetical-box', () => {
  it('scroll-parent-ref', async () => {
    let div;
    let target;
    div = create(
      'div',
      {
        overflow: 'auto',
        height: '100px',
        width: '200px',
        position: 'absolute',
        'background-image': 'linear-gradient(#e66465, #9198e5)',
      },
      [
        create('div', {
          width: '400px',
          height: '10px',
        }),
      ]
    );
    target = create('div', {}, [createText(`Modified text`)]);
    BODY.appendChild(div);
    BODY.appendChild(target);

    div.scrollLeft = 1000;

    await matchScreenshot();
  });
  it('scroll-parent', async () => {
    let target;
    let div;
    div = create(
      'div',
      {
        overflow: 'auto',
        height: '100px',
        width: '200px',
        'background-image': 'linear-gradient(#e66465, #9198e5)',
      },
      [
        (target = create(
          'div',
          {
            position: 'absolute',
          },
          [createText(`Modified text`)]
        )),
        create('div', {
          width: '400px',
          height: '10px',
        }),
      ]
    );
    BODY.appendChild(div);

    // Scroll the parent.
    div.scrollLeft = 1000;

    // Now force relayout of the abs pos div.
    target.textContent = 'Modified text';

    await matchScreenshot();
  });
  xit('scroll-viewport', async () => {
    let div;
    let div_1;
    div = create(
      'div',
      {
        position: 'absolute',
      },
      [createText(`Modified text`)]
    );
    div_1 = create('div', {
      width: '200vw',
      height: '10px',
    });
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    // Scroll the viewport.
    window.scrollTo(window.innerWidth * 2, 0);

    // Now force relayout of the abs pos div.
    div.textContent = 'Modified text';

    await matchScreenshot();
  });
  xit('scroll-viewport-ref', async () => {
    let div;
    let div_1;
    div = create('div', {}, [createText(`Modified text`)]);
    div_1 = create('div', {
      width: '200vw',
      height: '10px',
    });
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    window.scrollTo(window.innerWidth * 2, 0);

    await matchScreenshot();
  });
});
