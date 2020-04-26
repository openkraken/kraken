describe('BoxShadow', () => {
  it('basic usage', async () => {
    const reference = createElement('div', {
      width: '100px',
      height: '50px',
      backgroundColor: 'red',
      border: '1px solid black',
    });

    const div = createElement('div', {
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
});
