describe('Text TextIndent', () => {
  it('should work with normal', () => {
    // default to normal
    document.body.appendChild(document.createTextNode('\n there should \t\n\r be  no\n'));
    document.body.appendChild(document.createTextNode(' new line'));

    return matchScreenshot();
  });
});
