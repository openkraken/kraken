describe('br-element', () => {
  it('basic', async () => {
    const p = <p> Hello World! <br /> 你好，世界！</p>;
    document.body.appendChild(p);
    await snapshot();
  });
});
