describe('Tags template', () => {
  it('should work with content', async () => {
    const t = document.createElement('template')
    const template = t.content;
    template.appendChild(document.createTextNode('template text'))
    document.body.appendChild(template);

    await snapshot();
  });

  it('should work with innerHTML', async () => {
    const t = document.createElement('template')
    t.innerHTML = '<div>template text</div>';
    document.body.appendChild(t.content);
    expect(t.innerHTML).toBe('');
    await snapshot();
  });
});
