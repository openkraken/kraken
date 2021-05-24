// CSS Values and Units: https://drafts.csswg.org/css-values-3/#percentages
class CSSPercentage {
  static String PERCENTAGE = '%';

  static double? parsePercentage(String value) {
    double? parsed;
    if (value.endsWith(PERCENTAGE)) {
      double? v = double.tryParse(value.split(PERCENTAGE)[0]);
      if (v == null) return null;
      parsed = v / 100;
    }
    return parsed;
  }

  static bool isPercentage(String percentageValue) {
    return percentageValue.endsWith(PERCENTAGE);
  }
}
