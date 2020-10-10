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
});
