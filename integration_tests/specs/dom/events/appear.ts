describe('Appear Event', () => {
  it('trigger appear when appended', (done) => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';

    div.addEventListener('appear', function onAppear() {
      div.removeEventListener('appear', onAppear);
      done();
    });

    document.body.appendChild(div);
  });

  it('trigger disappear', (done) => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';
    div.style.position = 'absolute';
    div.style.top = '0';

    div.addEventListener('disappear', function onDisappear() {
      div.removeEventListener('disappear', onDisappear);
      done();
    });

    // Should must appear larger then 300ms means that have been appeared.
    setTimeout(() => {
      div.style.top = '-600px';
    }, 400);

    document.body.appendChild(div);
  });

  it('trigger appear when reappear', (done) => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';
    div.style.position = 'absolute';
    div.style.top = '0';

    setTimeout(() => {
      div.style.top = '-600px';
    }, 100);

    setTimeout(() => {
      div.style.top = '0';
    }, 200);

    document.body.appendChild(div);

    // should add eventListener after appendChild to
    // avoid first appear event when div has appended to document.body
    div.addEventListener('appear', function onAppear() {
      div.removeEventListener('appear', onAppear);
      done();
    });
  });
});
