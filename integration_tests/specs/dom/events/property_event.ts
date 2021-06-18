describe('Bind property event handler', () => {
  it('should work with setting property event handler', (done) => {
    let div = document.createElement('div');
    div.onclick = () => {
      clearTimeout(deadTimer);
      done();
    };
    let deadTimer = setTimeout(() => {
      done.fail('event handler not triggered')
    }, 500);
    document.body.appendChild(div);
    div.click();
  });

  it('should work with setting property event handler and addEventListener', (done) => {
    let div = document.createElement('div');
    let _index = 0;
    div.onclick = () => {
      _index++;
      clearTimeout(deadTimer);
      if (_index == 2) {
        done();
      }
    };
    div.addEventListener('click', () => {
      _index++;
      if (_index == 2) {
        done();
      }
    });
    let deadTimer = setTimeout(() => {
      done.fail('event handler not triggered')
    }, 500);
    document.body.appendChild(div);
    div.click();
  });

  it('should work with setting property event handler and addEventListener and and handler removed by removeEventListener', (done) => {
    let div = document.createElement('div');
    div.onclick = () => {
      clearTimeout(deadTimer);
      done();
    };
    function f() {
      done.fail('Event Handler should never triggered');
    }
    div.addEventListener('click', f);
    let deadTimer = setTimeout(() => {
      done.fail('event handler not triggered')
    }, 500);
    document.body.appendChild(div);
    div.removeEventListener('click', f);
    div.click();
  });

  it('should work with remove the property handler when setting null value', (done) => {
    let div = document.createElement('div');
    div.onclick = () => {
      done.fail('event handler should never triggered');
    };
    function f() {
      clearTimeout(deadTimer);
      done();
    }
    div.addEventListener('click', f);
    let deadTimer = setTimeout(() => {
      done.fail('event handler not triggered')
    }, 500);
    document.body.appendChild(div);
    div.onclick = null;
    div.click();
  });
});
