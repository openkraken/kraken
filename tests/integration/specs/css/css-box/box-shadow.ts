describe('BoxShadow', () => {
  it('basic usage', async () => {
    const reference = create('div', {
      width: '100px',
      height: '50px',
      backgroundColor: 'red',
      border: '1px solid black',
    });

    const div = create('div', {
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
