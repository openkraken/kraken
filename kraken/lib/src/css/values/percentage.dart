// CSS Values and Units: https://drafts.csswg.org/css-values-3/#percentages

class CSSPercentage {
  static String PERCENTAGE = '%';

  static double? parsePercentage(String value) {
    double? parsed;
    if (value.endsWith(PERCENTAGE)) {
      parsed = double.tryParse(value.split(PERCENTAGE)[0])! / 100;
    }
    return parsed;
  }

  static bool isPercentage(String? percentageValue) {
    return percentageValue != null && percentageValue.endsWith(PERCENTAGE);
  }
}
