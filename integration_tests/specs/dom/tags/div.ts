describe('Tags div', () => {
  it('basic', async () => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';

    document.body.appendChild(div);

    await matchViewportSnapshot();
  });
});
