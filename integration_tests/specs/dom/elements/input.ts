describe('Tags input', () => {
  it('basic', async () => {
    const input = document.createElement('input');
    input.style.width = '60px';
    input.style.fontSize = '16px';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    await snapshot();
  });

  it('with default width', async () => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.setAttribute('value', 'Hello World Hello World Hello World Hello World');
    document.body.appendChild(input);

    await snapshot();
  });

  it('with placeholder and value set', async () => {
    const input = document.createElement('input');
    input.style.width = '100px';
    input.setAttribute('placeholder', 'Please input');
    input.setAttribute('value', 'Hello World');

    document.body.appendChild(input);
    await snapshot();
  });

  it('with height smaller than text height', async () => {
    const input = document.createElement('input');
    input.style.fontSize = '26px';
    input.style.height = '22px';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    await snapshot();
  });

  it('with height larger than text height', async () => {
    const input = document.createElement('input');
    input.style.fontSize = '26px';
    input.style.height = '52px';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    await snapshot();
  });

  it('with value first', async () => {
    const input = document.createElement('input');
    input.setAttribute('value', 'Hello World Hello World Hello World Hello World');
    input.style.fontSize = '16px';
    document.body.appendChild(input);

    await snapshot();
  });

  it('type password', async () => {
    const div = document.createElement('div');
    const input = document.createElement('input');

    input.type = 'password';
    input.value = 'HelloWorld';
    input.placeholder = "This is placeholder.";

    div.appendChild(input);
    document.body.appendChild(div);

    await snapshot();
  });

  it('event blur', (done) => {
    const input1 = document.createElement('input');
    const input2 = document.createElement('input');
    input1.setAttribute('value', 'Input 1');
    input2.setAttribute('value', 'Input 2');
    document.body.appendChild(input1);
    document.body.appendChild(input2);

    input1.addEventListener('blur', function handler(event) {
      input1.removeEventListener('blur', handler);
      done();
    });

    input1.focus();
    input2.focus();
  });


  it('event focus', (done) => {
    const input1 = document.createElement('input');
    const input2 = document.createElement('input');
    input1.setAttribute('value', 'Input 1');
    input2.setAttribute('value', 'Input 2');
    document.body.appendChild(input1);
    document.body.appendChild(input2);

    input2.addEventListener('focus', function handler(event) {
      input2.removeEventListener('focus', handler);
      done();
    });

    input1.focus();
    input2.focus();

  });

  it('event input', (done) => {
    const VALUE = 'Hello';
    const input = document.createElement('input');
    input.value = '';
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      expect(event.type).toEqual('input');
      expect(event.target).toEqual(input);
      expect(event.currentTarget).toEqual(input);
      expect(event.bubbles).toEqual(false);
      done();
    });

    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateKeyPress(VALUE);
    });
  });

  it('support inputmode=text', (done) => {
    const VALUE = 'Hello';
    const input = <input inputmode="text" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateKeyPress(VALUE);
    });
  });

  it('support inputmode=tel', (done) => {
    const VALUE = '123456789';
    const input = <input inputmode="tel" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateKeyPress(VALUE);
    });
  });

  it('support inputmode=decimal', (done) => {
    const VALUE = '123456789';
    const input = <input inputmode="decimal" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateKeyPress(VALUE);
    });
  });

  it('support inputmode=numeric', (done) => {
    const VALUE = '123456789';
    const input = <input inputmode="numeric" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateKeyPress(VALUE);
    });
  });

  it('support inputmode=search', (done) => {
    const VALUE = 'Hello';
    const input = <input inputmode="search" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateKeyPress(VALUE);
    });
  });

  it('support inputmode=email', (done) => {
    const VALUE = 'example@example.com';
    const input = <input inputmode="email" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateKeyPress(VALUE);
    });
  });

  it('support inputmode=url', (done) => {
    const VALUE = 'example.com';
    const input = <input inputmode="url" />;
    input.addEventListener('input', function handler(event: InputEvent) {
      input.removeEventListener('input', handler);
      expect(input.value).toEqual(VALUE);
      done();
    });
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateKeyPress(VALUE);
    });
  });
});
