fdescribe('Blob slice', () => {
  it('with empty', () => {
    let blob = new Blob([new Int8Array([1, 2, 3, 4, 5])]);
    let another = blob.slice();
    expect(another.size).toBe(5);
  });

  it('with start', () => {
    let blob = new Blob([new Int8Array([1, 2, 3, 4, 5])]);
    let another = blob.slice(1);
    expect(another.size).toBe(4);
  });

  it('with start and end', () => {
    let blob = new Blob([new Int8Array([1, 2, 3, 4, 5])]);
    let another = blob.slice(1, 3);
    expect(another.size).toBe(2);
  });

})
