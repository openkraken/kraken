describe('BoxShadow', () => {
  it('basic usage', async () => {
    const reference = createElementWithStyle('div', {
      width: '100px',
      height: '50px',
      backgroundColor: 'red',
      border: '1px solid black',
    });

    const div = createElementWithStyle('div', {
      width: '50px',
      height: '50px',
      border: '1px solid black',
      backgroundColor: 'white',
      boxShadow: '50px 0px black',
    });
    append(reference, div);
    append(BODY, reference);
    await matchElementImageSnapshot(reference);
  });

  it('with background color', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'inline-block',
          width: '200px',
          height: '100px',
          margin: '20px',
          backgroundColor: 'green',
          boxShadow: '0 0 10px 5px rgba(0, 0, 0, 0.6)',
        },
      },
    );
    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('without background color and shadow offset', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'inline-block',
          width: '200px',
          height: '100px',
          margin: '20px',
          boxShadow: '0 0 10px 5px rgba(0, 0, 0, 0.6)',
        },
      },
    );
    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('with shadow blur and spread radius', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'inline-block',
          width: '200px',
          height: '100px',
          margin: '20px',
          boxShadow: '5px 5px 10px 0px rgba(0, 0, 0, 0.6)',
        },
      },
    );
    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('with border radius', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          display: 'inline-block',
          width: '200px',
          height: '100px',
          margin: '20px',
          borderRadius: '10px',
          boxShadow: '5px 5px 10px 0px rgba(0, 0, 0, 0.6)',
        },
      },
    );
    BODY.appendChild(div);
    await matchViewportSnapshot();
  });

  it('remove box-shadow', async () => {
    const div = createElementWithStyle('div', {
      width: '50px',
      height: '50px',
      border: '1px solid black',
      backgroundColor: 'white',
      margin: '10px',
      boxShadow: '0 0 8px black',
    });
    append(BODY, div);
    await matchViewportSnapshot();

    div.style.boxShadow = null;
    // BoxShadow has been removed.
    await matchViewportSnapshot();
  });

  it('change from not none to none', async (done) => {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          minHeight: '100px',
          width: '100px',
          backgroundColor: 'green',
          fontSize: '18px',
          boxShadow: '4px 4px 4px 0 red',
        }
      }
    );
    append(BODY, cont);

    await matchViewportSnapshot();

    requestAnimationFrame(async () => {
      cont.style.boxShadow = 'none';
      await matchViewportSnapshot(0.1);
      done();
    });
  });
});
