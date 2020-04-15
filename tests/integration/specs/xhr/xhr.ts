describe('XMLHttpRequest', () => {
  it('Get method success', function() {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        var status = xhr.status;
        expect(status).toBe(200);
        if ((status >= 200 && status < 300) || status == 304) {
          expect(xhr.responseText.replace(/\s+/g, '')).toBe(
            '{"method":"GET","data":{"userName":"12345"}}'
          );
        }
      }
    };
    xhr.open('GET', 'https://kraken.oss-cn-hangzhou.aliyuncs.com/data/data.json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    xhr.send();
  });

  it('Get method fail', function() {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        var status = xhr.status;
        expect(status).toBe(404);
      }
    };
    xhr.open('GET', 'https://kraken.oss-cn-hangzhou.aliyuncs.com/data/foo.json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    xhr.send();
  });

  it('POST method success', function() {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        var status = xhr.status;
        expect(status).toBe(200);
        if ((status >= 200 && status < 300) || status == 304) {
          expect(xhr.responseText).not.toBeNull();
        }
      }
    };
    xhr.open('POST', 'http://h5api.m.taobao.com/h5/mtop.common.gettimestamp/1.0/?api=mtop.common.gettimestamp&v=1.0&dataType=json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    xhr.send('foobar');
  });

  it('POST method fail', function() {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        expect(xhr.readyState).toBe(4);
        var status = xhr.status;
        expect(status).toBe(405);
      }
    };
    xhr.open('POST', 'https://kraken.oss-cn-hangzhou.aliyuncs.com/data/data.json', true);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    xhr.send('foobar');
  });
});
