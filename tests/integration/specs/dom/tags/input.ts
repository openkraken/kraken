describe('Tags input', () => {
  it('basic', async () => {
    const input = document.createElement('input');
    input.style.width = '60px';
    input.style.fontSize = '16px';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    await matchViewportSnapshot();
  });

  it('with default width', async () => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.setAttribute('value', 'Hello World Hello World Hello World Hello World');
    document.body.appendChild(input);

    await matchViewportSnapshot();
  });
});
