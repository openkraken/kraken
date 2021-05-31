// CSS Values and Units: https://drafts.csswg.org/css-values-3/#integers

// @dart=2.9

class CSSInteger {

  static int parseInteger(String value) {
    return int.tryParse(value);
  }

  static bool isInteger(String value){
    return int.tryParse(value) != null;
  }
}
