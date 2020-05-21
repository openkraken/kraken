const cookieStorage = {};

export const cookieGetterSetter = {
  cookie: {
    get() {
      const output = [];
      for (let cookieName in cookieStorage) {
        output.push(cookieName + '=' + cookieStorage[cookieName]);
      }
      return output.join(';');
    },
    set(str: String) {
      var idx = str.indexOf('=');
      var key = str.substr(0, idx);
      var value = str.substring(idx + 1);

      cookieStorage[key] = value;
      return key + '=' + value;
    }
  },
};
