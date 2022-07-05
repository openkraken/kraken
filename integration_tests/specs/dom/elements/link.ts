describe('Link Element', () => {
  it('should work with remote css', async (done) => {
    let link = document.createElement('link');
    link.setAttribute('href', 'https://andycall.oss-cn-beijing.aliyuncs.com/css/a-green.css');
    link.setAttribute('rel', 'stylesheet');

    link.addEventListener('load', async () => {
      await snapshot();
      done();
    });

    document.head.appendChild(link);

    let div = document.createElement('div');
    div.className = 'a';
    div.appendChild(document.createTextNode('helloworld'));
    BODY.appendChild(div);
  });
});