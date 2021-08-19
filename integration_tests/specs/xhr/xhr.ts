describe('XMLHttpRequest', () => {
  it('Get method success', (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        const status = xhr.status;
        expect(status).toBe(200);
        if ((status >= 200 && status < 300) || status == 304) {
          expect(JSON.parse(xhr.responseText)).toEqual({
            method: 'GET',
            data: { userName: "12345" }
          });
        }
        done();
      }
    };
    xhr.open('GET', `${MOCKED_HTTP_SERVER}/json_with_content_length_expires_etag_and_last_modified`, true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send();
  });

  it('Get method fail', (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        const status = xhr.status;
        expect(status).toBe(404);
        done();
      }
    };
    xhr.open('GET', 'https://kraken.oss-cn-hangzhou.aliyuncs.com/data/foo.json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send();
  });

  it('POST method success', (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        const status = xhr.status;
        expect(status).toBe(200);
        if ((status >= 200 && status < 300) || status == 304) {
          expect(xhr.responseText).not.toBeNull();
        }
        done();
      }
    };
    xhr.open('POST', 'http://h5api.m.taobao.com/h5/mtop.common.gettimestamp/1.0/?api=mtop.common.gettimestamp&v=1.0&dataType=json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send('foobar');
  });

  it('POST method fail', (done) => {
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        const status = xhr.status;
        expect(status).toBe(405);
        done();
      }
    };
    xhr.open('POST', 'https://kraken.oss-cn-hangzhou.aliyuncs.com/data/data.json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send('foobar');
  });
});
