interface Async_storage {
  setItem(key: string, value: string): Promise<void>;

  getItem(key: string): Promise<string>;

  removeItem(key: string): Promise<void>;

  getAllKeys(): Promise<Array<string>>;

  clear(): Promise<void>;
}

declare const asyncStorage: Async_storage;

describe('asyncStorage', () => {
  beforeEach(async () => {
    await asyncStorage.clear();
  });

  it('getItem', async () => {
    await asyncStorage.setItem('keyValue', '12345');
    let value = await asyncStorage.getItem('keyValue');
    expect(value).toBe('12345');
  });

  it('removeItem', async () => {
    await asyncStorage.setItem('keyValue', '12345');
    await asyncStorage.removeItem('keyValue');
    let value = await asyncStorage.getItem('keyValue');
    expect(value).toBe('');
  });

  it('clear', async () => {
    await asyncStorage.setItem('keyA', '1');
    await asyncStorage.setItem('keyB', '1');
    let beforeKeys = await asyncStorage.getAllKeys();
    expect(beforeKeys.length).toBe(2);
    await asyncStorage.clear();
    let keys = await asyncStorage.getAllKeys();
    expect(keys.length).toBe(0);
  });
});