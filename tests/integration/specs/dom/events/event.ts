describe('Event', () => {
  it('should work with order', async () => {
    const container1 = document.createElement('div');
    document.body.appendChild(container1);
    setElementStyle(container1, {
      padding: '20px',
      backgroundColor: '#999',
      margin: '40px',
    });
    container1.appendChild(document.createTextNode('DIV 1'));

    const container2 = document.createElement('div');
    setElementStyle(container2, {
      padding: '20px',
      height: '100px',
      backgroundColor: '#f40',
      margin: '40px',
    });
    container2.appendChild(document.createTextNode('DIV 2'));

    container1.appendChild(container2);

    document.body.addEventListener('click', function listener() {
      wrapper.appendChild(document.createTextNode('BODY clicked, '));
      document.body.removeEventListener('click', listener);
    });
    container1.addEventListener('click', () => {
      wrapper.appendChild(document.createTextNode('DIV 1 clicked, '));
    });
    container2.addEventListener('click', () => {
      wrapper.appendChild(document.createTextNode('DIV 2 clicked, '));
    });

    const wrapper = document.createElement('div');
    document.body.appendChild(wrapper);
    wrapper.appendChild(document.createTextNode('Click DIV 2: '));

    container2.click();
    await matchViewportSnapshot();
  });

  it('do not trigger click when scrolling', async () => {
    let clickCount = 0;
    let container;
    let list:any = [];
    for (let i = 0; i < 100; i ++) {
      list.push(i);
    }
    let scroller;
    container = createViewElement(
      {
        width: '200px',
        height: '500px',
        flexShrink: 1,
        border: '2px solid #000',
      },
      [
        createViewElement(
          {
            height: '20px',
          },
          []
        ),
        scroller = createViewElement(
          {
            flex: 1,
            width: '200px',
            overflow: 'scroll',
          },
          list.map(index => {
            let element =  createElement('div', {}, [createText(`${index}`)]);
            element.onclick = () => {
              clickCount += 1;
            }
            return element;
          })
        ),
      ]
    );

    BODY.appendChild(container);

    await simulateClick(20, 60);
    await simulateSwipe(20, 100, 20, 20, 0.1);
    expect(clickCount).toBe(1);
  });

  it('text node can not trigger click', async () => {
    let clickCount =  0;
    const text = createText('text');
    BODY.appendChild(text);
    text.addEventListener('click', () => {
      clickCount++;
    });
    await simulateClick(10, 10);
    expect(clickCount).toBe(0);
  });

  it('when the node transforms, the click event triggers the wrong node', async () => {
    let clickText = '';

    const div = document.createElement('div');
    setElementStyle(div, {
      position: 'absolute',
      width: '80px',
      height: '30px',
      backgroundColor: 'red',
    });
    div.addEventListener('click', function listener() {
      clickText = 'red';
      div.removeEventListener('click', listener);
    });

    const div2 = document.createElement('div');
    setElementStyle(div2, {
      position: 'absolute',
      width: '80px',
      height: '30px',
      backgroundColor: 'blue',
      transform: 'translate3d(0px, 60px, 0px) scale(1, 1)',
    });
    div2.addEventListener('click', function listener() {
      clickText = 'blue';
      div2.removeEventListener('click', listener);
    });

    document.body.appendChild(div);
    document.body.appendChild(div2);
    await simulateClick(20, 20);
    expect(clickText).toBe('red');
  });

  it('scroll to the invisible container range', async () => {
    let clickCount = 0;

    const container = document.createElement('div');

    container.style.overflow = 'hidden';
    container.style.width = '300px';
    container.style.height = '500px';
    container.style.backgroundColor = 'blue';

    document.body.appendChild(container);

    const container2 = document.createElement('div');

    container2.style.overflow = 'scroll';
    container2.style.width = '300px';
    container2.style.height = '500px';
    container2.style.marginTop = '200px';
    container2.style.backgroundColor = 'red';

    const block1 =document.createElement('div');
    block1.style.width = '100px';
    block1.style.height = '100px';
    block1.style.backgroundColor = 'yellow';

    const block =document.createElement('div');
    block.style.width = '100px';
    block.style.height = '100px';
    block.style.backgroundColor = 'green';
    block.addEventListener('click', () => clickCount++); 

    const block2 =document.createElement('div');
    block2.style.width = '100px';
    block2.style.height = '700px';
    block2.style.backgroundColor = 'yellow';

    container.appendChild(container2);
    container2.appendChild(block1);
    container2.appendChild(block);
    container2.appendChild(block2);

    container2.scrollTo(0, 150);

    await simulateClick(50, 530);
    await simulateClick(50, 470);
    expect(clickCount).toBe(1);
  })
});
