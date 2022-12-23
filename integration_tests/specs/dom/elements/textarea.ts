describe('Tags textarea', () => {
  it('basic', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.width = '60px';
    textarea.style.fontSize = '16px';
    const text = document.createTextNode('Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    await snapshot();
  });

  it('works with child text node appended when value property not exist', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    const text = document.createTextNode('Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      const text = document.createTextNode('Hello World');
      textarea.appendChild(text);
      await snapshot();
      done();
    });
  });

  it('works with child text node changed data when value property not exist', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    const text = document.createTextNode('Hello World');

    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      text.data = 'Hello World Hello World Hello World';
      await snapshot();
      done();
    });
  });

  it('works with child text node inserted data when value property not exist', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    const text = document.createTextNode('inserted text');
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.insertBefore(text, null);
      await snapshot();
      done();
    });
  });

  it('works with child text node replaced when value property not exist', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    const text = document.createTextNode('Hello World');
    const text2 = document.createTextNode('replaced text');

    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.replaceChild(text2, text);
      await snapshot();
      done();
    });
  });

  it('works with child text node removed when value property not exist', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    const text = document.createTextNode('Hello World');

    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.removeChild(text);
      await snapshot();
      done();
    });
  });

  it('does works with child text node appended when value property exists', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.value = 'setted value';
    const text = document.createTextNode('Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      const text = document.createTextNode('Hello World');
      textarea.appendChild(text);
      await snapshot();
      done();
    });
  });
  it('does not work with child text node changed data when value property exists', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.value = 'setted value';
    const text = document.createTextNode('Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      text.data = 'Hello World Hello World Hello World';
      await snapshot();
      done();
    });
  });

  it('does not work with child text node inserted data when value property exists', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.value = 'setted value';
    const text = document.createTextNode('inserted text');
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.insertBefore(text, null);
      await snapshot();
      done();
    });
  });

  it('does not work with child text node replaced when value property exists', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.value = 'setted value';
    const text = document.createTextNode('Hello World');
    const text2 = document.createTextNode('replaced text');

    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.replaceChild(text2, text);
      await snapshot();
      done();
    });
  });

  it('does not work with child text node removed when value property exists', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.value = 'setted value';
    const text = document.createTextNode('Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.removeChild(text);
      await snapshot();
      done();
    });
  });

  it('with multiple text node child', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.setAttribute('rows', '10');
    const text1 = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text1);
    const text2 = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text2);
    document.body.appendChild(textarea);

    await snapshot();
  });

  it('with default width and height', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    const text = document.createTextNode('Hello World Hello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    await snapshot();
  });

  it('with rows attribute', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.setAttribute('rows', '10');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    await snapshot();
  });

  it('with cols attribute', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.setAttribute('cols', '10');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    await snapshot();
  });

  it('with rows attribute change when height is not set', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.setAttribute('rows', '20');
      await snapshot();
      done();
    });
  });

  it('with rows attribute change when height is set', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.style.height = '200px';
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.setAttribute('rows', '20');
      await snapshot();
      done();
    });
  });

  it('with rows attribute set and height changed to auto', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.setAttribute('rows', '20');
    textarea.style.height = '200px';
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.style.height = 'auto';
      await snapshot();
      done();
    });
  });

  it('with cols attribute change when width is not set', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.setAttribute('cols', '30');
      await snapshot();
      done();
    });
  });

  it('with cols attribute change when width is set', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.style.width = '150px';
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.setAttribute('cols', '30');
      await snapshot();
      done();
    });
  });

  it('with cols attribute set and width changed to auto', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.setAttribute('cols', '30');
    textarea.style.width = '150px';
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    requestAnimationFrame(async () => {
      textarea.style.width = 'auto';
      await snapshot();
      done();
    });
  });

  it('with defaultValue property', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.setAttribute('rows', '10');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    textarea.defaultValue = 'Hello World\nHello World';
    document.body.appendChild(textarea);

    await snapshot();
  });
  
  it('with value property', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.setAttribute('rows', '10');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    textarea.value = 'Hello World\nHello World';
    document.body.appendChild(textarea);

    await snapshot();
  });

  it('with placeholder', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.setAttribute('placeholder', 'Please input text.');
    document.body.appendChild(textarea);

    await snapshot();
  });

  it('with placeholder and value', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.setAttribute('placeholder', 'Please input text.');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    await snapshot();
  });

  it('with height smaller than text height', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '26px';
    textarea.style.height = '22px';
    textarea.setAttribute('placeholder', 'Please input text.');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    await snapshot();
  });

  it('with height larger than text height', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '26px';
    textarea.style.height = '120px';
    textarea.setAttribute('placeholder', 'Please input text.');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    await snapshot();
  });

  it('height not set and line-height set', async () => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.style.lineHeight = '30px';
    textarea.setAttribute('rows', '10');
    textarea.setAttribute('placeholder', 'Please input text.');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    await snapshot();
  });
  it('line-height changes when height is not set', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.style.lineHeight = '20px';
    textarea.setAttribute('rows', '10');
    textarea.setAttribute('placeholder', 'Please input text.');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    await snapshot();

    requestAnimationFrame(async () => {
      textarea.style.lineHeight = '30px';
      await snapshot();
      done();
    });
  });

  it('line-height changes when height is set', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.style.height = '120px';
    textarea.style.lineHeight = '20px';

    textarea.setAttribute('rows', '10');
    textarea.setAttribute('placeholder', 'Please input text.');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);

    document.body.appendChild(textarea);

    await snapshot();

    requestAnimationFrame(async () => {
      textarea.style.lineHeight = '30px';
      await snapshot();
      done();
    });
  });

  it('font-size changes when width and height not set', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.setAttribute('rows', '10');
    textarea.setAttribute('placeholder', 'Please input text.');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    await snapshot();

    requestAnimationFrame(async () => {
      textarea.style.fontSize = '28px';
      await snapshot();
      done();
    });
  });

  it('font-size changes when width and height is set', async (done) => {
    const textarea = document.createElement('textarea');
    textarea.style.fontSize = '16px';
    textarea.style.width = '160px';
    textarea.style.height = '160px';
    textarea.setAttribute('rows', '10');
    textarea.setAttribute('placeholder', 'Please input text.');
    const text = document.createTextNode('Hello World\nHello World Hello World Hello World');
    textarea.appendChild(text);
    document.body.appendChild(textarea);

    await snapshot();

    requestAnimationFrame(async () => {
      textarea.style.fontSize = '28px';
      await snapshot();
      done();
    });
  });
  
  it('event blur', (done) => {
    const textarea1 = document.createElement('textarea');
    const textarea2 = document.createElement('textarea');
    textarea1.value = 'Textarea 1';
    textarea2.value = 'Textarea 2';
    document.body.appendChild(textarea1);
    document.body.appendChild(textarea2);

    textarea1.addEventListener('blur', function handler(event) {
      textarea2.removeEventListener('blur', handler);
      done();
    });

    textarea1.focus();
    textarea2.focus();
  });


  it('event focus', (done) => {
    const textarea1 = document.createElement('textarea');
    const textarea2 = document.createElement('textarea');
    textarea1.value = 'Textarea 1';
    textarea2.value = 'Textarea 2';
    document.body.appendChild(textarea1);
    document.body.appendChild(textarea2);

    textarea1.addEventListener('focus', function handler(event) {
      textarea2.removeEventListener('focus', handler);
      done();
    });

    textarea1.focus();
    textarea2.focus();
  });

  it('event input', (done) => {
    const VALUE = 'Hello';
    const textarea = document.createElement('input');
    textarea.value = '';
    textarea.addEventListener('input', function handler(event: InputEvent) {
      textarea.removeEventListener('input', handler);
      expect(textarea.value).toEqual(VALUE);
      expect(event.type).toEqual('input');
      expect(event.target).toEqual(textarea);
      expect(event.currentTarget).toEqual(textarea);
      expect(event.bubbles).toEqual(false);
      done();
    });

    document.body.appendChild(textarea);
    textarea.focus();
    requestAnimationFrame(() => {
      simulateInputText(VALUE);
    });
  });

  it('event change', (done) => {
    const VALUE = 'Textarea 3';
    const textarea1 = document.createElement('input');
    const textarea2 = document.createElement('input');
    textarea1.value = 'Textarea 1';
    textarea2.value = 'Textarea 2';
    document.body.appendChild(textarea1);
    document.body.appendChild(textarea2);

    textarea1.addEventListener('change', function handler(event) {
      expect(textarea1.value).toEqual(VALUE);      
      done();
    });

    textarea1.focus();

    requestAnimationFrame(() => {
      textarea1.value = VALUE;
      textarea2.focus(); 
    });
  });

  it('support maxlength', (done) => {
    const textarea = document.createElement('textarea');
    textarea.setAttribute('maxlength', '3');
    document.body.appendChild(textarea);
    textarea.focus();
    requestAnimationFrame(() => {
      simulateInputText('1');
      requestAnimationFrame(() => {
        expect(textarea.value).toEqual('1');

        simulateInputText('123');
        requestAnimationFrame(() => {
          expect(textarea.value).toEqual('123');

          simulateInputText('1234');
          requestAnimationFrame(() => {
            expect(textarea.value).toEqual('123');
            done();
          });
        });
      });
    });
  });

  it('should work with click', (done) => {
    const textarea = document.createElement('textarea');
    textarea.value = 'Textarea 1';
    document.body.appendChild(textarea);
    textarea.addEventListener('click', function handler() {
      done();
    });

    simulateClick(10, 10);
  });

  it('should return empty string when set value to null', () => {
    const textarea = document.createElement('textarea');
    document.body.appendChild(textarea);
    textarea.value = '1234';
    expect(textarea.value).toBe('1234');
    // @ts-ignore
    textarea.value = null;
    expect(textarea.value).toBe('');
  });

  it('textarea attribute and property value priority', () => {
    let text;
    const textarea = createElement('textarea', {
      rows: 10, 
      cols: 10,
      placeholder: '9999999',
      style: {
        height: '200px',
      }
    }, [
      (text = createText('hello world'))
    ]) as HTMLTextAreaElement;
    document.body.appendChild(textarea);

    text.data = 'text content value';
    expect(textarea.defaultValue).toBe('text content value');
    expect(textarea.value).toBe('text content value');

    textarea.defaultValue = 'default value';
    expect(textarea.defaultValue).toBe('default value');
    expect(textarea.value).toBe('default value');

    textarea.value = 'property value';
    expect(textarea.defaultValue).toBe('default value');
    expect(textarea.value).toBe('property value');

    text.data = 'text content value 2';
    expect(textarea.defaultValue).toBe('text content value 2');
    expect(textarea.value).toBe('property value');
  });
});
