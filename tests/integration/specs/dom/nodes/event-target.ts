/**
 * Test DOM API for Element:
 * - EventTarget.prototype.addEventListener
 * - EventTarget.prototype.removeEventListener
 * - EventTarget.prototype.dispatchEvent
 */
describe('DOM EventTarget', () => {
  it('should work', async () => {
    let clickTime = 0;
    const div = document.createElement('div');

    const clickHandler = () => {
      clickTime++;
    };
    div.addEventListener('click', clickHandler);

    document.body.appendChild(div);
    div.click();
    div.click();

    div.removeEventListener('click', clickHandler);
    div.click();

    // Only 2 times recorded.
    expect(clickTime).toBe(2);
  });

  it('addEventListener should work normally', (done) => {
    let div = create('div', {});
    div.addEventListener('click', () => {
      done();
    });
    document.body.appendChild(div);
    div.click();
  });

  xit('addEventListener should work without connected into element tree', done => {
    let div = create('div', {});
    div.addEventListener('click', () => {
      done();
    });
    div.click();
  });

  it('addEventListener should work with multi event handler', done => {
    let count = 0;
    let div1 = create('div', {});
    let div2 = create('div', {});
    div1.addEventListener('click', () => {
      count++;
    });

    div2.addEventListener('click', () => {
      count++;
      if (count == 2) {
        done();
      }
    });

    BODY.appendChild(div1);
    BODY.appendChild(div2);
    div1.click();
    div2.click();
  });

  it('addEventListener should work with removeEventListeners', () => {
    let div = create('div', {});
    let count = 0;
    function onClick() {
      count++;
      div.removeEventListener('click', onClick);
    }
    div.addEventListener('click', onClick);

    BODY.appendChild(div);
    div.click();
    div.click();
    div.click();
    div.addEventListener('click', onClick);
    expect(count).toBe(1);
  });

  it('should work with build in property handler', (done) => {
    let div = create('div', {});
    div.onclick = () => {
      done();
    };
    BODY.appendChild(div);
    div.click();
  });

  it('event object should have type', done => {
    let div = create('div', {});
    div.addEventListener('click', (event: any) => {
      expect(event.type).toBe('click');
      done();
    });
    BODY.appendChild(div);
    div.click();
  });

  it('event object target should equal to element itself', done => {
    let div = create('div', {});
    div.addEventListener('click', (event: any) => {
      expect(div === event.target);
      done();
    });
    BODY.appendChild(div);
    div.click();
  });

  it('event object currentTarget should equal to element itself', done => {
    let div = create('div', {});
    div.addEventListener('click', (event: any) => {
      expect(div === event.currentTarget);
      done();
    });
    BODY.appendChild(div);
    div.click();
  });

  it('trigger twice when onclick and bind addEventListener', () => {
    let div = create('div', {});
    let count = 0;
    div.addEventListener('click', (event: any) => {
      count++;
    });
    div.onclick = () => {
      count++;
    }
    BODY.appendChild(div);
    div.click();
    expect(count).toBe(2);
  });
});
