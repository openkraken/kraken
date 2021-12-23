describe('custom widget element', () => {
  it('use flutter text', async () => {
    const text = document.createElement('flutter-text');
    text.setAttribute('value', 'Hello');
    document.body.appendChild(text);

    await snapshot();

    text.setAttribute('value', 'Hi');
    await snapshot();
  });

  it('should work with html tags', async () => {
    let div = document.createElement('div');
    div.innerHTML = `<flutter-text value="Hello" />`;
    document.body.appendChild(div);
    await snapshot();

    div.innerHTML = `<flutter-text value="Hi"></flutter-text>`;
    await snapshot();
  });

  it('use flutter asset image', async () => {
    const image = document.createElement('flutter-asset-image');
    image.setAttribute('src', 'assets/rabbit.png');
    document.body.appendChild(image);

    await snapshot(0.1);
  });

  it('work with click event', async (done) => {
    const image = document.createElement('flutter-asset-image');
    image.setAttribute('src', 'assets/rabbit.png');
    document.body.appendChild(image);

    image.addEventListener('click', function (e) {
      done();
    });

    simulateClick(20, 20);
  });

  it('text node should be child of flutter container', async () => {
    const container = document.createElement('flutter-container');
    const text = document.createTextNode('text');
    document.body.appendChild(container);
    container.appendChild(text);
    await snapshot();
  });

  it('element should be child of flutter container', async () => {
    const container = document.createElement('flutter-container');
    const element = document.createElement('div');
    element.style.width = '30px';
    element.style.height = '30px';
    element.style.backgroundColor = 'red';
    container.appendChild(element);
    document.body.appendChild(container);
    await snapshot();
  });

  it('flutter widget should be child of flutter container', async () => {
    const container = document.createElement('flutter-container');
    const fluttetText = document.createElement('flutter-text');
    fluttetText.setAttribute('value', 'text');
    container.appendChild(fluttetText);
    document.body.appendChild(container);

    await snapshot();
  });

  it('flutter widget and dom node should be child of flutter container', async () => {
    const container = document.createElement('flutter-container');
    document.body.appendChild(container);

    const element = document.createElement('div');
    element.style.backgroundColor = 'red';
    element.appendChild(document.createTextNode('div element'));
    container.appendChild(element);

    const fluttetText = document.createElement('flutter-text');
    fluttetText.setAttribute('value', 'text');
    container.appendChild(fluttetText);

    const text = document.createTextNode('text');
    container.appendChild(text);

    await snapshot();
  });

  it('flutter widget should be child of element', async () => {
    const container = document.createElement('div');
    container.style.width = '100px';
    container.style.height = '100px';
    container.style.backgroundColor = 'red';
    const element = document.createElement('flutter-text');
    element.setAttribute('value', 'text');
    container.appendChild(element);
    document.body.appendChild(container);

    await snapshot();
  });

  it('flutter widget should be child of element and the element should be child of flutter widget', async () => {
    const container = document.createElement('flutter-container');
    document.body.appendChild(container);

    const childContainer = document.createElement('div');
    container.appendChild(childContainer);

    const fluttetText = document.createElement('flutter-text');
    fluttetText.setAttribute('value', 'text');
    childContainer.appendChild(fluttetText);

    await snapshot();
  });

  it('should work with waterfall-flow', async () => {
    const flutterContainer = document.createElement('waterfall-flow');
    flutterContainer.style.height = '100vh';
    flutterContainer.style.display = 'block';

    document.body.appendChild(flutterContainer);

    const colors = ['red', 'yellow', 'black', 'blue', 'green'];

    for (let i = 0; i < 10; i++) {
      const div = document.createElement('div');
      div.style.width = '100%';
      div.style.border = `1px solid ${colors[i % colors.length]}`;
      div.appendChild(document.createTextNode(`${i}`));

      const img = document.createElement('img');
      img.src = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png';
      div.appendChild(img);
      img.style.width = '100px';

      flutterContainer.appendChild(div);
    }

    await snapshot();
  });
});

describe('custom html element', () => {
  it('works with document.createElement', async () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);
    await snapshot();
  });

  it('support custom properties in dart directly', () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);

    // @ts-ignore
    expect(sampleElement.ping).toBe('pong');
  });

  it('support call js function but defined in dart directly', () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);

    let arrs = [1, 2, 4, 8, 16];
    // @ts-ignore
    expect(sampleElement.fn.apply(sampleElement, arrs)).toEqual([2, 4, 8, 16, 32]);
  });

  it('return promise when dart return future async function', async () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);
    // @ts-ignore
    let p = sampleElement.asyncFn(1);
    expect(p instanceof Promise);
    let result = await p;
    expect(result).toBe(1);
    // @ts-ignore
    let p2 = sampleElement.asyncFn('abc');
    expect(await p2).toBe('abc');

    // @ts-ignore
    let p3 = sampleElement.asyncFn([1, 2, 3, 4]);
    expect(await p3).toEqual([1, 2, 3, 4]);

    // @ts-ignore
    let p4 = sampleElement.asyncFn([{ name: 1 }]);
    expect(await p4).toEqual([{ name: 1 }]);
  });

  it('return promise error when dart async function throw error', async () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);
    // @ts-ignore
    let p = sampleElement.asyncFnFailed();
    expect(p instanceof Promise);
    try {
      let result = await p;
      throw new Error('should throw');
    } catch (e) {
      expect(e.message).toBe('Assertion failed: "Asset error"');
    }
  });

  it('property with underscore have no effect', () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);

    // @ts-ignore
    expect(sampleElement._fake).toBe(undefined);

    // @ts-ignore
    sampleElement._fake = [1, 2, 3, 4, 5];
    // @ts-ignore
    expect(sampleElement._fake).toEqual([1, 2, 3, 4, 5]);
  });
});
