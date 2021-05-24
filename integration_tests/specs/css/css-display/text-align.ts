describe('text-align', () => {
  it('001', async () => {
    let container = createElementWithStyle('div', {
      width: '200px',
      'text-align': 'center',
    });
    let text = createText('Filter Text');
    let div = createElementWithStyle('div', {
      width: '200px',
      height: '20px',
      backgroundColor: 'blue',
    });

    append(container, createElementWithStyle('p', {}, createText('test passes if "Filler Text" is centered above the blue stripe.')));
    append(container, text);
    append(container, div);
    append(BODY, container);
    await snapshot(container);
  });
});
