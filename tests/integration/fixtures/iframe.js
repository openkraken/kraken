it('iframe', () => {
  return new Promise((done) => {
    // There are no load event fired at desktop kraken.
    // MOCK async logic.
    setTimeout(done, 2000);

    const iframe = document.createElement('iframe');
    iframe.setAttribute('src', 'https://dev.g.alicdn.com/kraken/kraken-demos/todomvc/build/web/index.html');
    iframe.style.width = '100vw';
    iframe.style.height = '375rpx';

    const div = document.createElement('div');
    div.style.width = div.style.height = '200px';
    div.style.backgroundColor = 'cyan';
    document.body.appendChild(div);
    document.body.appendChild(iframe);

    const div2 = document.createElement('div');
    div2.style.width = div2.style.height = '100px';
    div2.style.backgroundColor = 'red';
    document.body.appendChild(div2);
  });
});
