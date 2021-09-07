import 'package:kraken/css.dart';

const int SLASH_CODE = 47; // /
const int NEWLINE_CODE = 10; // \n
const int SPACE_CODE = 32; // ' '
const int FEED_CODE = 12; // \f
const int TAB_CODE = 9; // \t
const int CR_CODE = 13; // \r
const int OPEN_CURLY_CODE = 123; // {
const int CLOSE_CURLY_CODE = 125; // }
const int SEMICOLON_CODE = 59; // ;
const int ASTERISK_CODE = 42; // *
const int COLON_CODE = 58; // :
const int OPEN_PARENTHESES_CODE = 40; // (
const int CLOSE_PARENTHESES_CODE = 41; // )
const int SINGLE_QUOTE_CODE = 39; // ';
const int DOUBLE_QUOTE_CODE = 34; // "
const int HYPHEN_CODE = 45; // -

const int _SELECTOR = 0;
const int _NAME = 1;
const int _VALUE = 2;
const int _FUNCTION = 3;
const int _END = 4;

const String _END_OF_COMMENT = '*/';
const String _EMPTY_STRING = '';

class CSSStyleRuleParser {
  static CSSStyleRule parse(String ruleText) {
    String selectorText = _EMPTY_STRING;
    CSSStyleDeclaration style = CSSStyleDeclaration();

    StringBuffer buffer = StringBuffer();
    int state = _SELECTOR;
    String propertyName = _EMPTY_STRING;
    bool isString = false;
    bool isCustomProperty = false;

    for (int pos = 0, length = ruleText.length; pos < length && state != _END; pos++) {
      int c = ruleText.codeUnitAt(pos);

      if (c == SINGLE_QUOTE_CODE || c == DOUBLE_QUOTE_CODE) {
        isString = !isString;
      }

      if (isString) {
        buffer.writeCharCode(c);
        continue;
      }

      switch (c) {
        case SPACE_CODE:
        case TAB_CODE:
        case CR_CODE:
        case FEED_CODE:
        case NEWLINE_CODE:
          if ((state == _SELECTOR || state == _VALUE) && pos > 0) {
            // Squash 2 or more white-spaces in the row into 1 space.
            switch (ruleText.codeUnitAt(pos - 1)) {
              case SPACE_CODE:
              case TAB_CODE:
              case CR_CODE:
              case FEED_CODE:
              case NEWLINE_CODE:
                break;
              default:
                buffer.writeCharCode(SPACE_CODE);
                break;
            }
          } else if (state == _FUNCTION) {
            buffer.writeCharCode(c);
          }
          break;
        case HYPHEN_CODE:
          if (state == _NAME && isCustomProperty == false) {
            int letter = ruleText.codeUnitAt(pos + 1);
            if (letter == HYPHEN_CODE) {
              // Ignore css custom properties: `--main-bg-color`.
              buffer.writeCharCode(c);
              isCustomProperty = true;
              break;
            }
            // Convert background-image to backgroundImage
            // a-z: 97-122
            if (letter > 96 && letter < 123) {
              // Convert to upper case: A-Z: 65-90
              letter = letter - 32;
              buffer.writeCharCode(letter);
              pos++;
            }
          } else {
            buffer.writeCharCode(c);
          }
          break;
        case SLASH_CODE:
          if (ruleText.codeUnitAt(pos + 1) == ASTERISK_CODE) {
            // This is a comment, find the end of the comment.
            pos += 2;
            int index = ruleText.indexOf(_END_OF_COMMENT, pos);
            if (index == -1) {
              // Unterminated comment
              state = _END;
            } else {
              pos = index + 2;
            }
          } else {
            buffer.writeCharCode(c);
          }
          break;
        case OPEN_CURLY_CODE:
          if (state == _SELECTOR) {
            selectorText = buffer.toString().trim();
            buffer.clear();
            state = _NAME;
          } else {
            // Unexpected {
            state = _END;
          }
          break;
        case COLON_CODE:
          if (state == _NAME) {
            propertyName = buffer.toString().trim();
            buffer.clear();
            // Reset isCustomProperty flag.
            isCustomProperty = false;
            state = _VALUE;
          } else {
            buffer.writeCharCode(c);
          }
          break;
        case CLOSE_PARENTHESES_CODE:
          if (state == _FUNCTION) {
            buffer.writeCharCode(c);
            state = _VALUE;
          } else {
            buffer.writeCharCode(c);
          }
          break;
        case OPEN_PARENTHESES_CODE:
          // This is a function, find the end of the function.
          if (state == _VALUE) {
            state = _FUNCTION;
          }

          // Pseudo-class selector: `th:nth-child(4)`
          // Function value: `url()`, `rgb()`
          buffer.writeCharCode(c); // Write (
          break;
        case SEMICOLON_CODE:
          if (state == _FUNCTION) {
            // In data uri function
            buffer.writeCharCode(c);
          } else {
            // `{ col;or: red; }` will parsed as {col: '', or: 'red'}
            if (propertyName.isNotEmpty) {
              String value = buffer.toString().trim();
              if (value.isNotEmpty) style.setProperty(propertyName, value);
              propertyName = _EMPTY_STRING;
            }
            buffer.clear();
            // Skip empty property declaration like `color: red; ;;`.
            state = _NAME;
          }
          break;
        case CLOSE_CURLY_CODE:
          if (state == _VALUE && propertyName.isNotEmpty) {
            // `body { color: red }` that not end with semicolon is
            // also the end of the declaration.
            style.setProperty(propertyName, buffer.toString().trim());
          }
          state = _END;
          break;
        default:
          buffer.writeCharCode(c);
          break;
      }
    }

    return CSSStyleRule(selectorText, style);
  }
}
