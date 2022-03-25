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

  it('with size attribute', async () => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.setAttribute('value', 'Hello World Hello World Hello World Hello World');
    input.setAttribute('size', '10');
    document.body.appendChild(input);

    await snapshot();
  });

    
  it('with size attribute change when width is not set', async (done) => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    requestAnimationFrame(async () => {
      input.setAttribute('size', '30');
      await snapshot();
      done();
    });
  });

  it('with cols attribute change when width is set', async (done) => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.style.width = '100px';
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    requestAnimationFrame(async () => {
      input.setAttribute('size', '30');
      await snapshot();
      done();
    });
  });

  it('with size attribute set and width changed to auto', async (done) => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.style.width = '100px';
    input.setAttribute('size', '30');
    input.setAttribute('value', 'Hello World');
    document.body.appendChild(input);

    requestAnimationFrame(async () => {
      input.style.width = 'auto';
      await snapshot();
      done();
    });
  });
  
  it('with defaultValue property', async () => {
    const input = document.createElement('input');
    input.style.fontSize = '16px';
    input.defaultValue = 'Hello World Hello World Hello World Hello World';
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

  it('height not set and line-height set', async () => {
    let div;
    div = createElement(
      'input',
      {
        value: '1234567890',
        style: {
            lineHeight: '50px',
            fontSize: '30px',
        },
      }
    );
    BODY.appendChild(div);
  });

  // @TODO: line-height should not take effect for input element itself.
  xit('line-height set and is smaller than text size', async (done) => {
    let input;
    input = createElement(
      'input',
      {
        value: '1234567890',
        style: {
            lineHeight: '10px',
            fontSize: '30px'
        },
      }
    );
    BODY.appendChild(input);

    await snapshot();
  });

  it('line-height set and is bigger than text size', async () => {
    let input;
    input = createElement(
      'input',
      {
        value: '1234567890',
        style: {
            lineHeight: '100px',
            fontSize: '30px'
        },
      }
    );
    BODY.appendChild(input);

    await snapshot();
  });

  it('line-height changes when height is not set', async (done) => {
    let input;
    input = createElement(
      'input',
      {
        value: '1234567890',
        style: {
          lineHeight: '50px',
        },
      }
    );
    BODY.appendChild(input);

    await snapshot();

    requestAnimationFrame(async () => {
      input.style.lineHeight = '100px';
      await snapshot();
      done();
    });
  });

  it('font-size set and width not set', async () => {
    let input;
    input = createElement(
      'input',
      {
        value: '1234567890',
        style: {
          fontSize: '30px'
        },
      }
    );
    BODY.appendChild(input);

    await snapshot();
  });

  it('font-size changes when width not set', async (done) => {
    let input;
    input = createElement(
      'input',
      {
        value: '1234567890',
        style: {
        },
      }
    );
    BODY.appendChild(input);

    await snapshot();

    requestAnimationFrame(async () => {
      input.style.fontSize = '30px';
      await snapshot();
      done();
    });
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
      simulateInputText(VALUE);
    });
  });

  it('event change', (done) => {
    const VALUE = 'Input 3';
    const input1 = document.createElement('input');
    const input2 = document.createElement('input');
    input1.setAttribute('value', 'Input 1');
    input2.setAttribute('value', 'Input 2');
    document.body.appendChild(input1);
    document.body.appendChild(input2);

    input1.addEventListener('change', function handler(event) {
      expect(input1.value).toEqual(VALUE);      
      done();
    });

    input1.focus();

    requestAnimationFrame(() => {
      input1.setAttribute('value', VALUE);
      input2.focus(); 
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
      simulateInputText(VALUE);
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
      simulateInputText(VALUE);
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
      simulateInputText(VALUE);
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
      simulateInputText(VALUE);
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
      simulateInputText(VALUE);
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
      simulateInputText(VALUE);
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
      simulateInputText(VALUE);
    });
  });

  it('support maxlength', (done) => {
    const input = <input maxlength="3" />;
    document.body.appendChild(input);
    input.focus();
    requestAnimationFrame(() => {
      simulateInputText('1');
      requestAnimationFrame(() => {
        expect(input.value).toEqual('1');

        simulateInputText('123');
        requestAnimationFrame(() => {
          expect(input.value).toEqual('123');

          simulateInputText('1234');
          requestAnimationFrame(() => {
            expect(input.value).toEqual('123');
            done();
          });
        });
      });
    });
  });

  it('support work with click', (done) => {
    const input = document.createElement('input');
    input.setAttribute('value', 'Input 1');
    document.body.appendChild(input);
    input.addEventListener('click', function handler() {
      done();
    });

    simulateClick(10, 10);
  });

  it('should return empty string when set value to null', () => {
    const input = document.createElement('input');
    document.body.appendChild(input);
    input.value = '1234';
    expect(input.value).toBe('1234');
    // @ts-ignore
    input.value = null;
    expect(input.value).toBe('');
  });

  it('input attribute and property value priority', () => {
    const input = createElement('input', {
      placeholder: 'hello world',
      style: {
        height: '50px',
      }
    });
    document.body.appendChild(input);

    input.setAttribute('value', 'attribute value');
    // @ts-ignore
    expect(input.defaultValue).toBe('attribute value');
    // @ts-ignore
    expect(input.value).toBe('attribute value');

    // @ts-ignore
    input.defaultValue = 'default value';
    // @ts-ignore
    expect(input.defaultValue).toBe('default value');
    // @ts-ignore
    expect(input.value).toBe('default value'); 

    // @ts-ignore
    input.value = 'property value';
    // @ts-ignore
    expect(input.defaultValue).toBe('default value');
    // @ts-ignore
    expect(input.value).toBe('property value'); 
 
    input.setAttribute('value', 'attribute value 2');
    // @ts-ignore
    expect(input.defaultValue).toBe('attribute value 2');
    // @ts-ignore
    expect(input.value).toBe('property value'); 
  });
});
