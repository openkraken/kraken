// https://drafts.csswg.org/css-values-3/#functional-notations
class CSSFunction {
  String name;
  List<String> args;

  CSSFunction(this.name, this.args);

  static Map<String, CSSFunction> parseExpression(String src) {
    int start = 0;
    int left = src.indexOf('(', start);
    int right = src.indexOf(')', start);
    Map<String, CSSFunction> functions = {};
    while (left != -1 && right != -1 && right > left + 1) {
      String args = src.substring(left + 1, right).trim();
      List<String> argList = args.split(',');
      String fn = src.substring(start, left);
      CSSFunction fnMap = CSSFunction(fn.trim(), argList);
      functions[fn] = fnMap;
      start = right + 1;
      left = src.indexOf('(', start);
      right = src.indexOf(')', start);
    }
    return functions;
  }
}
