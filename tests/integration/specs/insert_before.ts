describe('DOM insert before', () => {
  it('basic', async () => {
    var div = document.createElement('div');
    var span = document.createElement('span');
    var textNode = document.createTextNode('Hello');
    span.appendChild(textNode);
    div.appendChild(span);
    document.body.appendChild(div);

    var insertText = document.createTextNode('World');
    var insertSpan = document.createElement('span');
    insertSpan.appendChild(insertText);
    div.insertBefore(insertSpan, span);

    await matchScreenshot();
  });
});
