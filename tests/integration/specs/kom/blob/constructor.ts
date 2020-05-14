describe('Blob construct', () => {
  it('with string', async () => {
    let blob = new Blob(['1234']);
    expect(blob.size).toBe(4);
    let text = await blob.text();
    expect(text).toBe('1234');
  });

  it('with another blob', async () => {
    let blob = new Blob(['1234']);
    let another = new Blob([blob]);
    expect(another.size).toBe(4);
    expect(await another.text()).toBe('1234');
  });

  it('with arrayBuffer', async () => {
    let arrayBuffer = await new Blob(['1234']).arrayBuffer();
    let blob = new Blob([arrayBuffer]);
    expect(blob.size).toBe(4);
    expect(await blob.text()).toBe('1234');
  });

  it('with arrayBufferView', async () => {
    let buffer = new Int8Array([97, 98, 99, 100, 101]);
    let blob = new Blob([buffer]);
    expect(await blob.text()).toBe('abcde');
    expect(blob.size).toBe(5);
  });
});
