describe('custom widget element', () => {
  it('use flutter text', async () => {
    const text = document.createElement('flutter-text');
    text.setAttribute('value', 'Hello');
    document.body.appendChild(text);

    await snapshot();

    text.setAttribute('value', 'Hi');
    await snapshot(0.1);
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

    image.addEventListener('click', function(e){
      done();
    });

    simulateClick(20, 20);
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
    let p3 = sampleElement.asyncFn([1,2,3,4]);
    expect(await p3).toEqual([1,2,3,4]);

    // @ts-ignore
    let p4 = sampleElement.asyncFn([{name: 1}]);
    expect(await p4).toEqual([{name: 1}]);
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
    } catch(e) {
      expect(e.message).toBe('Assertion failed: "Asset error"');
    }
  });

  it('property with underscore have no effect', () => {
    let sampleElement = document.createElement('sample-element');
    let text = document.createTextNode('helloworld');
    sampleElement.appendChild(text);
    document.body.appendChild(sampleElement);

    // @ts-ignore
    expect(sampleElement._fake).toBe(null);

    // @ts-ignore
    sampleElement._fake = [1,2,3,4,5];
    // @ts-ignore
    expect(sampleElement._fake).toEqual([1,2,3,4,5]);
  });
});
