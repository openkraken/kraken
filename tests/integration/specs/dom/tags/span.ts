describe('Tags span', () => {
  it('should work with texts', async () => {
    const span = document.createElement('span');
    const text = document.createTextNode('hello world');
    span.appendChild(text);

    span.style.fontSize = '80px';
    span.style.textDecoration = 'line-through';
    span.style.fontWeight = 'bold';
    span.style.fontStyle = 'italic';
    span.style.fontFamily = 'arial';
    document.body.appendChild(span);

    const span2 = document.createElement('span');
    const text2 = document.createTextNode('hello world');
    span2.appendChild(text2);

    span2.style.fontSize = '40px';
    span2.style.textDecoration = 'underline';
    span2.style.fontWeight = 'lighter';
    span2.style.fontStyle = 'normal';
    span2.style.fontFamily = 'georgia';
    document.body.appendChild(span2);

    await matchViewportSnapshot();
  });
});
