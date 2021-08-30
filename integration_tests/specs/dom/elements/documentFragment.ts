describe('Tags documentFragment', () => {
  it('support appendChild', async () => {
    const list = document.createElement('div');
    document.body.appendChild(list);

    const colors = ['red', 'green', 'blue', 'black'];

    const fragment = new DocumentFragment();

    colors.forEach(color => {
      const ele = document.createElement('div');
      ele.style.width = '100px';
      ele.style.height = '100px';
      ele.style.backgroundColor = color;
      fragment.appendChild(ele);
    });

    list.appendChild(fragment);

    await snapshot();
  });

  it('basic', async () => {
    const list = document.createElement('div');
    document.body.appendChild(list);

    const e = document.createElement('div');
    e.style.width = '100px';
    e.style.height = '100px';
    e.style.backgroundColor = 'yellow';
    list.appendChild(e);

    const colors = ['red', 'green', 'blue', 'black'];

    const fragment = new DocumentFragment();

    colors.forEach(color => {
      const ele = document.createElement('div');
      ele.style.width = '100px';
      ele.style.height = '100px';
      ele.style.backgroundColor = color;
      fragment.appendChild(ele);
    });

    list.insertBefore(fragment, e);

    await snapshot();
  });
});
