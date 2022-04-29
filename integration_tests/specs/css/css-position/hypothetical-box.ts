/*auto generated*/
describe('hypothetical-box', () => {
  it('scroll-parent-ref', async () => {
    let div;
    let target;
    div = createElementWithStyle(
      'div',
      {
        overflow: 'auto',
        height: '100px',
        width: '200px',
        position: 'absolute',
        'background-image': 'linear-gradient(#e66465, #9198e5)',
      },
      [
        createElementWithStyle('div', {
          width: '400px',
          height: '10px',
        }),
      ]
    );
    target = createElementWithStyle('div', {}, [createText(`Modified text`)]);
    BODY.appendChild(div);
    BODY.appendChild(target);

    div.scrollLeft = 1000;

    await snapshot();
  });
  it('scroll-parent', async () => {
    let target;
    let div;
    div = createElementWithStyle(
      'div',
      {
        overflow: 'auto',
        height: '100px',
        width: '200px',
        'background-image': 'linear-gradient(#e66465, #9198e5)',
      },
      [
        (target = createElementWithStyle(
          'div',
          {
            position: 'absolute',
          },
          [createText(`Modified text`)]
        )),
        createElementWithStyle('div', {
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

    await snapshot();
  });
  it('scroll-viewport', async () => {
    let div;
    let div_1;
    div = createElementWithStyle(
      'div',
      {
        position: 'absolute',
      },
      [createText(`Modified text`)]
    );
    div_1 = createElementWithStyle('div', {
      width: '200vw',
      height: '10px',
    });
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    // Scroll the viewport.
    window.scrollTo(window.innerWidth * 2, 0);

    // Now force relayout of the abs pos div.
    div.textContent = 'Modified text';

    await snapshot();
  });
  it('scroll-viewport-ref', async () => {
    let div;
    let div_1;
    div = createElementWithStyle('div', {}, [createText(`Modified text`)]);
    div_1 = createElementWithStyle('div', {
      width: '200vw',
      height: '10px',
    });
    BODY.appendChild(div);
    BODY.appendChild(div_1);

    window.scrollTo(window.innerWidth * 2, 0);

    await snapshot();
  });
});
