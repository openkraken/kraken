describe('Link Element', () => {
  it('should work with remote css', async () => {
    let link = document.createElement('link');
    link.href = 'assets://a-green.css';
    link.rel = 'stylesheet';
    document.head.appendChild(link);

    let div = document.createElement('div');
    div.className = 'a';
    div.appendChild(document.createTextNode('helloworld'));
    BODY.appendChild(div);

    await snapshot();
  });
});