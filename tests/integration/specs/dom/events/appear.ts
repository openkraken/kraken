describe('Appear Event', () => {
  it('trigger appear when appended', (done) => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';

    div.addEventListener('appear', () => {
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

    div.addEventListener('disappear', () => {
      done();
    });

    setTimeout(() => {
      div.style.top = '-600px';
    }, 100);

    document.body.appendChild(div);
  });

  it('trigger appear when reappear', (done) => {
    const div = document.createElement('div');
    div.style.width = '300px';
    div.style.height = '300px';
    div.style.backgroundColor = 'red';
    div.style.position = 'absolute';
    div.style.top = '0';

    div.addEventListener('appear', () => {
      done();
    });

    setTimeout(() => {
      div.style.top = '-600px';
    }, 100);

    setTimeout(() => {
      div.style.top = '0';
    }, 200);

    document.body.appendChild(div);
  });
});
