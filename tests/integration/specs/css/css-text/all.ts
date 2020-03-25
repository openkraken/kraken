describe('Text', () => {
  it('001', async () => {
    document.body.appendChild(document.createTextNode('\n there should \t\n\r be  no\n'));
    document.body.appendChild(document.createTextNode(' new line'));

    await matchScreenshot();
  });
});
