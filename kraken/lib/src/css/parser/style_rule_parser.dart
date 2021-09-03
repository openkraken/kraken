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

const int _SELECTOR = 0;
const int _NAME = 1;
const int _VALUE = 2;
const int _END = 3;

const String _END_OF_COMMENT = '*/';
const String _END_OF_PARENTHESES = ')';
const String _EMPTY_STRING = '';

class CSSStyleRuleParser {
  static CSSStyleRule parse(String ruleText) {
    String selectorText = _EMPTY_STRING;
    CSSStyleDeclaration style = CSSStyleDeclaration();

    StringBuffer buffer = StringBuffer();
    int state = _SELECTOR;
    String propertyName = _EMPTY_STRING;

    for (int pos = 0, length = ruleText.length; pos < length && state != _END; pos++) {
      int c = ruleText.codeUnitAt(pos);
      switch (c) {
        case SPACE_CODE:
        case TAB_CODE:
        case CR_CODE:
        case FEED_CODE:
        case NEWLINE_CODE:
          if (state == _SELECTOR || state == _VALUE) {
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
            state = _VALUE;
          } else {
            buffer.writeCharCode(c);
          }
          break;
        case OPEN_PARENTHESES_CODE:
          // This is a function, find the end of the function.
          if (state == _VALUE) {
            int index = ruleText.indexOf(_END_OF_PARENTHESES, pos);
            if (index == -1) {
              // Unterminated parenthesis
              state = _END;
            } else {
              pos = index + 1;
            }
          } else {
            // Unexpected parenthesis
            state = _END;
          }
          break;
        case SEMICOLON_CODE:
          // `{ col;or: red; }` will parsed as {col: '', or: 'red'}
          if (propertyName.isNotEmpty) {
            style.setProperty(propertyName, buffer.toString().trim());
            propertyName = _EMPTY_STRING;
            buffer.clear();
          }
          // Skip empty property declaration like `color: red; ;;`.
          state = _NAME;
          break;
        case CLOSE_CURLY_CODE:
          if (state == _NAME) {
            // `{ col}or: red }` will parsed as {col: ''}
            propertyName = buffer.toString().trim();
            if (propertyName.isNotEmpty) {
              style.setProperty(propertyName, _EMPTY_STRING);
            }
          } if (state == _VALUE && propertyName.isNotEmpty) {
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
