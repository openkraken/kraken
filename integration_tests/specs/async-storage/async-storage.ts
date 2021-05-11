interface AsyncStorage {
  setItem(key: number | string, value: number | string): Promise<void>;
  getItem(key: number | string): Promise<string>;
  removeItem(key: number | string): Promise<void>;
  getAllKeys(): Promise<Array<string>>;
  clear(): Promise<void>;
  length(): Promise<number>;
}

declare const asyncStorage: AsyncStorage;

describe('AsyncStorage', () => {
  beforeEach(async () => {
    await asyncStorage.clear();
  });

  it('should work with getItem', async () => {
    await asyncStorage.setItem('keyValue', '12345');
    let value = await asyncStorage.getItem('keyValue');
    expect(value).toBe('12345');
  });

  it('should work with setItem and removeItem', async () => {
    await asyncStorage.setItem('keyValue', '12345');
    await asyncStorage.removeItem('keyValue');
    let value = await asyncStorage.getItem('keyValue');
    expect(value).toBe('');
  });

  it('should work with setItem and clear and getAllKeys', async () => {
    await asyncStorage.setItem('keyA', '1');
    await asyncStorage.setItem('keyB', '1');
    let beforeKeys = await asyncStorage.getAllKeys();
    expect(beforeKeys.length).toBe(2);
    await asyncStorage.clear();
    let keys = await asyncStorage.getAllKeys();
    expect(keys.length).toBe(0);
  });

  it('should work with getItem when key is a number', async () => {
    await asyncStorage.setItem(111, '111');
    let value = await asyncStorage.getItem(111);
    expect(value).toBe('111');
  });

  it('should work with getItem when value is a number', async () => {
    await asyncStorage.setItem('111', 111);
    let value = await asyncStorage.getItem('111');
    expect(value).toBe('111');
  });

  it('should work with getItem when key and value are both numbers', async () => {
    await asyncStorage.setItem(111, 111);
    let value = await asyncStorage.getItem(111);
    expect(value).toBe('111');
  });

  it('should work with setItem and removeItem when key is a number', async () => {
    await asyncStorage.setItem(333, '12345');
    let val1 = await asyncStorage.getItem(333);
    expect(val1).toBe('12345');
    await asyncStorage.removeItem(333);
    let val2 = await asyncStorage.getItem(333);
    expect(val2).toBe('');
  });

  it('should work with setItem and removeItem when value is a number', async () => {
    await asyncStorage.setItem('333', 12345);
    let val1 = await asyncStorage.getItem('333');
    expect(val1).toBe('12345');
    await asyncStorage.removeItem('333');
    let val2 = await asyncStorage.getItem('333');
    expect(val2).toBe('');
  });

  it('should work with setItem and removeItem when key and value are both numbers', async () => {
    await asyncStorage.setItem(666, 12345);
    let val1 = await asyncStorage.getItem(666);
    expect(val1).toBe('12345');
    await asyncStorage.removeItem(666);
    let val2 = await asyncStorage.getItem(666);
    expect(val2).toBe('');
  });

  it('should work with setItem and clear and getAllKeys when key and value are both numbers', async () => {
    await asyncStorage.setItem(333, 666);
    await asyncStorage.setItem(222, 888);
    let beforeKeys = await asyncStorage.getAllKeys();
    expect(beforeKeys.length).toBe(2);
    await asyncStorage.clear();
    let keys = await asyncStorage.getAllKeys();
    expect(keys.length).toBe(0);
  });

  it('should work with length', async () => {
    const zero = await asyncStorage.length();
    expect(zero).toBe(0);

    await asyncStorage.setItem(333, 666);
    const one = await asyncStorage.length();
    expect(one).toBe(1);
  });
});
