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
