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

  it('with int16Array', async () => {
    let buffer = new Int16Array([100, 101, 102, 103, 104]);
    let blob = new Blob([buffer]);
    let arrayBuffer = await blob.arrayBuffer();
    let u8Array = new Uint8Array(arrayBuffer);
    expect(Array.from(u8Array)).toEqual([100, 0, 101, 0, 102, 0, 103, 0, 104, 0]);
  });
});
