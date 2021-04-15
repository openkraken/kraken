describe('Clone node', () => {
  it('with a div when deep is true', async () => {
    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';
    div.style.backgroundColor = 'yellow';
    div.setAttribute('id', '123');
    document.body.appendChild(div)

    const div2 = div.cloneNode(true);
    document.body.appendChild(div2)

    await snapshot();
  });

  it('with a div when deep is false', async () => {
    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';
    div.style.backgroundColor = 'yellow';
    div.setAttribute('id', '123');
    document.body.appendChild(div)

    const div2 = div.cloneNode(true);
    document.body.appendChild(div2)

    await snapshot();
  });

  it('with Multi-level div nesting when deep is true', async () => {
    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';
    div.style.backgroundColor = 'green';
    div.setAttribute('id', '123');
    document.body.appendChild(div)

    const child = document.createElement('div');
    child.style.width = '10px';
    child.style.height = '10px';
    child.style.backgroundColor = 'blue';
    div.setAttribute('id', 'child123');
    div.appendChild(child);

    const child2 = document.createElement('div');
    child2.style.width = '10px';
    child2.style.height = '10px';
    child2.style.backgroundColor = 'yellow';
    div.setAttribute('id', 'child123');
    div.appendChild(child2);

    const div2 = div.cloneNode(true);
    document.body.appendChild(div2)

    await snapshot();
  });

  it('with Multi-level div nesting when deep is false', async () => {
    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';
    div.style.backgroundColor = 'green';
    div.setAttribute('id', '123');
    document.body.appendChild(div)

    const child = document.createElement('div');
    child.style.width = '10px';
    child.style.height = '10px';
    child.style.backgroundColor = 'blue';
    div.setAttribute('id', 'child123');
    div.appendChild(child);

    const child2 = document.createElement('div');
    child2.style.width = '10px';
    child2.style.height = '10px';
    child2.style.backgroundColor = 'yellow';
    div.setAttribute('id', 'child123');
    div.appendChild(child2);

    const div2 = div.cloneNode(false);
    document.body.appendChild(div2)

    await snapshot();
  });

  it('text node', async () => {
    const text = document.createTextNode('text');
    document.body.appendChild(text);

    const text2 = text.cloneNode(true);
    document.body.appendChild(text2);

    await snapshot();
  });

  it('element node nested text node', async () => {
    const div = document.createElement('div');
    div.style.color = 'blue';
    const text = document.createTextNode('text');
    document.body.appendChild(div);
    div.appendChild(text);

    const div2 = div.cloneNode(true);
    document.body.appendChild(div2);

    await snapshot();
  });
});
  