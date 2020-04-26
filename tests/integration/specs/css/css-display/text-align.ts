describe('text-align', () => {
  it('001', async () => {
    let container = createElement('div', {
      width: '200px',
      'text-align': 'center',
    });
    let text = createText('Filter Text');
    let div = createElement('div', {
      width: '200px',
      height: '20px',
      backgroundColor: 'blue',
    });

    append(container, createElement('p', {}, createText('test passes if "Filler Text" is centered above the blue stripe.')));
    append(container, text);
    append(container, div);
    append(BODY, container);
    await matchElementImageSnapshot(container);
  });
});
