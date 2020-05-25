const cookieStorage = {};

// @TODO Persisent cookie and Session cookie support
export const cookie = {
  get() {
    const output = [];
    for (let cookieName in cookieStorage) {
      output.push(cookieName + '=' + cookieStorage[cookieName]);
    }
    return output.join(';');
  },
  set(str: String) {
    const idx = str.indexOf('=');
    const key = str.substr(0, idx);
    const value = str.substring(idx + 1);

    cookieStorage[key] = value;
    return key + '=' + value;
  }
};
