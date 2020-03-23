describe('BoxShadow', () => {
  xit('', async () => {
    let reference = create('div', {
      width: '100px',
      height: '50px',
      backgroundColor: 'red',
      border: '1px solid black',
    });

    let div = create('div', {
      width: '50px',
      height: '50px',
      border: '1px solid black',
      backgroundColor: 'white',
      boxShadow: 'black 50px 0px',
    });
    append(reference, div);
    append(BODY, reference);
    await matchElementImageSnapshot(reference);
  });
});
