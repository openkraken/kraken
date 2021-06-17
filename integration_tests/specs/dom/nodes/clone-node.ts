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

  it('should work with img element', async (done) => {
    const img = document.createElement('img');
    img.style.width = '100px';
    img.style.height = '100px';
    img.src = "assets/kraken.png";
    document.body.appendChild(img);
    const img2 = img.cloneNode(false);
    document.body.appendChild(img2);

    let anotherImgHasLoad = false;
    async function loadImg() {
      if (anotherImgHasLoad) {
        await snapshot();
        done();
      } else {
        anotherImgHasLoad = true;
      }
    }

    img.addEventListener('load', loadImg);
    img2.addEventListener('load', loadImg);
  })

  it('deep is not required', async () => {
    const div = document.createElement('div');
    div.style.width = '100px';
    div.style.height = '100px';
    div.style.backgroundColor = 'red';
    const divChild = document.createElement('div');
    divChild.style.width = '50px';
    divChild.style.height = '50px';
    divChild.style.backgroundColor = 'yellow';
    document.body.appendChild(div);
    div.appendChild(divChild);

    const divClone = div.cloneNode();
    document.body.appendChild(divClone);

    await snapshot();
  })
});
  