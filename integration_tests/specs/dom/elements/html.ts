describe('html', () => {
  it('should exist', async () => {
    expect(document.documentElement).toBeDefined();
    expect(document.documentElement.appendChild).toBeDefined();
  });

  it('tagName is HTML', async () => {
    expect(document.documentElement.tagName).toBe('HTML');
  });

  it('parentNode is document', async () => {
    expect(document.documentElement.parentNode).toBe(document);
  });

  
});
