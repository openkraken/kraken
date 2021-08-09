describe('Tags div', () => {
  it('basic', async () => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';

    document.body.appendChild(div);

    await snapshot();
  });
  
  it('instanceof HTMLElement', () => {
    let div = document.createElement('div');
    expect(div instanceof Element).toBe(true);
    expect(div instanceof HTMLElement).toBe(true);

  });
});
