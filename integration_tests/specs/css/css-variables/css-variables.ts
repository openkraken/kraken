describe('CSS Variables', () => {
  // https://github.com/web-platform-tests/wpt/blob/master/css/css-variables/css-variable-change-style-001.html
  it('change-style-001', async () => {

    document.body.appendChild(createStyle(`
      .outer {
        --x: red;
        --y: green;
        --z: 28px;
      }
    `));
    document.head.appendChild(createStyle(`
      .inner {
        font-size: var(--z);
      }
    `));

    document.body.appendChild(
      <div class="outer">
        <div class="inbetween">
          <div class="inner">FontSize should be 28px.</div>
        </div>
      </div>
    );

    await snapshot();
  });

  it('change-style-002', async () => {
    document.head.appendChild(createStyle(`
      .inner {

        --x: red;
        --y: green;
        --z: 28px;
        font-size: var(--z);
      }
    `));

    document.body.appendChild(
      <div class="outer">
        <div class="inbetween">
          <div class="inner">FontSize should be 28px.</div>
        </div>
      </div>
    );

    await snapshot();
  });


  it('variable resolve color', async () => {
    document.head.appendChild(createStyle(`
      .inner {
        --x: red;
        --y: green;
        --z: 28px;
        background: var(--x);
      }
    `));

    document.body.appendChild(
      <div class="outer">
        <div class="inbetween">
          <div class="inner">Background should be red.</div>
        </div>
      </div>
    );

    await snapshot();
  });

  function createStyle(text) {
    const style = document.createElement('style');
    style.appendChild(document.createTextNode(text));
    return style;
  }
});