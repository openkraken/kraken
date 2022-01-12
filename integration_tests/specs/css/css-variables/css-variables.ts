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
        background-color: var(--x);
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

  it('nested variables', async () => {
    document.head.appendChild(createStyle(`
     .inner {
        color: var(--x);
      }
      .outer {
        --y: red;
        --x: var(--y);
      }
    `));

    document.body.appendChild(
      <div class="outer">
        <div class="inbetween">
          <div class="inner">Color should be red.</div>
        </div>
      </div>
    );

    await snapshot();
  });

  describe('Shorthand CSS properties', () => {
    it('background', async () => {
      document.head.appendChild(createStyle(`
        .inner {
          --x: red;
          --y: green;
          --z: 28px;
          background: var(--y);
        }
      `));

      document.body.appendChild(
        <div class="outer">
          <div class="inbetween">
            <div class="inner">Background should be green.</div>
          </div>
        </div>
      );

      await snapshot();
    });

    it('margin', async () => {
      document.head.appendChild(createStyle(`
        .inner {
          --x: red;
          --y: green;
          --z: 28px;
          margin: var(--z);
          background: red;
        }
      `));

      document.body.appendChild(
        <div class="outer">
          <div class="inbetween">
            <div class="inner">Background should be red with 28px margin.</div>
          </div>
        </div>
      );

      await snapshot();
    });

    it('padding', async () => {
      document.head.appendChild(createStyle(`
        .inner {
          --x: red;
          --y: green;
          --z: 28px;
          padding: var(--z);
          background: red;
        }
      `));

      document.body.appendChild(
        <div class="outer">
          <div class="inbetween">
            <div class="inner">Background should be red with 28px padding.</div>
          </div>
        </div>
      );

      await snapshot();
    });

    it('border', async () => {
      document.head.appendChild(createStyle(`
        .inner {
          --x: 4px;
          --y: solid;
          --z: green;
          border: var(--x) var(--y) var(--z);
          background: red;
        }
      `));

      document.body.appendChild(
        <div class="outer">
          <div class="inbetween">
            <div class="inner">Background should be red with 4px green solid border.</div>
          </div>
        </div>
      );

      await snapshot();
    });
  });

  function createStyle(text) {
    const style = document.createElement('style');
    style.appendChild(document.createTextNode(text));
    return style;
  }
});
