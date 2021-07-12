fdescribe('custom element', () => {
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
