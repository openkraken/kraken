it('getItem', async () => {
  await asyncStorage.setItem('keyValue', '12345');
  let value = await asyncStorage.getItem('keyValue');
  assert.equal(value, '12345');
});

it('removeItem', async () => {
  await asyncStorage.setItem('keyValue', '12345');
  await asyncStorage.removeItem('keyValue');
  let value = await asyncStorage.getItem('keyValue');
  assert.equal(value, '');
});

it('clear', async () => {
  await asyncStorage.setItem('keyA', '1');
  await asyncStorage.setItem('keyB', '1');
  let beforeKeys = await asyncStorage.getAllKeys();
  assert.equal(beforeKeys.length, 2);
  await asyncStorage.clear();
  let keys = await asyncStorage.getAllKeys();
  assert.equal(keys.length, 0);
});