describe('Tag style', () => {
  it('simple usage', async () => {
    const style = document.createElement('style');
    style.appendChild(document.createTextNode(`.foo {
      color: red;
      text-align: center;
    }`));
    document.body.appendChild(style);

    const div = document.createElement('div');
    div.appendChild(document.createTextNode('HelloWorld'));
    div.className = "foo";

    document.body.appendChild(div);
    await snapshot();
  });

  it('dynamic append text child into style', async () => {
    const style = document.createElement('style');
    document.body.appendChild(style);

    const div = document.createElement('div');
    div.appendChild(document.createTextNode('HelloWorld'));
    div.className = "foo";

    document.body.appendChild(div);

    await sleep(0.1);
    // Insert text after all things done.
    style.appendChild(document.createTextNode(`.foo {
      color: red;
      text-align: center;
    }`));

    await snapshot();
  });
});
