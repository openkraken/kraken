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
    let div = createElementWithStyle('div', {});
    div.addEventListener('click', () => {
      done();
    });
    document.body.appendChild(div);
    div.click();
  });

  it('addEventListener should work without connected into element tree', done => {
    let div = createElementWithStyle('div', {});
    div.addEventListener('click', () => {
      done();
    });
    div.click();
  });

  it('addEventListener should work with multi event handler', done => {
    let count = 0;
    let div1 = createElementWithStyle('div', {});
    let div2 = createElementWithStyle('div', {});
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
    let div = createElementWithStyle('div', {});
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
    let div = createElementWithStyle('div', {});
    div.onclick = () => {
      done();
    };
    BODY.appendChild(div);
    div.click();
  });

  it('event object should have type', done => {
    let div = createElementWithStyle('div', {});
    div.addEventListener('click', (event: any) => {
      expect(event.type).toBe('click');
      done();
    });
    BODY.appendChild(div);
    div.click();
  });

  it('event object target should equal to element itself', done => {
    let div = createElementWithStyle('div', {});
    div.addEventListener('click', (event: any) => {
      expect(div === event.target);
      done();
    });
    BODY.appendChild(div);
    div.click();
  });

  it('event object currentTarget should equal to element itself', done => {
    let div = createElementWithStyle('div', {});
    div.addEventListener('click', (event: any) => {
      expect(div === event.currentTarget);
      done();
    });
    BODY.appendChild(div);
    div.click();
  });

  it('trigger twice when onclick and bind addEventListener', () => {
    let div = createElementWithStyle('div', {});
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

  it('stop propagation', () => {
    let count1 = 0, count2 = 0;

    const div1 = document.createElement('div');
    const div2 = document.createElement('div');
    div1.appendChild(div2);
    div1.addEventListener('click', (event) => {
      count1++;
    });
    div2.addEventListener('click', (event) => {
      count2++;
      event.stopPropagation();
    });
    document.body.appendChild(div1);

    div2.click();
    div2.click();

    expect(count1).toBe(0);
    expect(count2).toBe(2);
  });

  it('stop immediately propagation', () => {
    const div = document.createElement('div');
    document.body.appendChild(div);

    let shouldNotBeTrue = false;

    div.addEventListener('click', (event: Event) => {
      event.stopImmediatePropagation();
    });
    div.addEventListener('click', () => {
      // Unreach code.
      shouldNotBeTrue = true;
    });
    expect(shouldNotBeTrue).toEqual(false);
  });

});
