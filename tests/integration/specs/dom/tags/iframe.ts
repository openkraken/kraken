describe('IframeElement', () => {
  it('basic', async () => {
    const iframe = document.createElement('iframe');
    iframe.setAttribute(
      'src',
      'https://dev.g.alicdn.com/kraken/kraken-demos/todomvc/build/web/index.html'
    );
    iframe.style.width = '360px';
    iframe.style.height = '375px';

    const div = document.createElement('div');
    div.style.width = div.style.height = '200px';
    div.style.backgroundColor = 'cyan';
    document.body.appendChild(div);
    document.body.appendChild(iframe);

    const div2 = document.createElement('div');
    div2.style.width = div2.style.height = '100px';
    div2.style.backgroundColor = 'red';
    document.body.appendChild(div2);

    // There are no load event fired at desktop kraken.
    // MOCK async logic.
    await sleep(2);
    await matchViewportSnapshot();
  });
});
