describe('head', () => {
  it('should exist', async () => {
    expect(document.head).toBeDefined();
    expect(document.head.appendChild).toBeDefined();
  });
});
