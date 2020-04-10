class Method {
  String name;
  List<String> args;

  Method(this.name, this.args);

  static Map<String, Method> parseMethod(String src) {
    int start = 0;
    int left = src.indexOf('(', start);
    int right = src.indexOf(')', start);
    Map<String, Method> methods = {};
    while (left != -1 && right != -1 && right > left + 1) {
      String args = src.substring(left + 1, right).trim();
      List<String> argList = args.split(',');
      String method = src.substring(start, left);
      Method methodMap = Method(method.trim(), argList);
      methods[method] = methodMap;
      start = right + 1;
      left = src.indexOf('(', start);
      right = src.indexOf(')', start);
    }
    return methods;
  }
}
