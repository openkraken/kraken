describe('text-align', () => {
  it('test passes if "Filler Text" is centered above the blue stripe.', async () => {
    let container = create('div', {
      width: '200px',
      'text-align': 'center'
    });
    let text = createText('Filter Text');
    let div = create('div', {
      width: '200px',
      height: '20px',
      backgroundColor: 'blue'
    });

    append(container, text);
    append(container, div);
    append(BODY, container);
    await matchElementImageSnapshot(container);
  });
});
