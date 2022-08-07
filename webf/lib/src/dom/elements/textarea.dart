/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/foundation.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';

const String TEXTAREA = 'TEXTAREA';
const String ROWS = 'rows';
const String COLS = 'cols';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  BORDER: '1px solid #767676',
};

class TextareaElement extends TextFormControlElement {
  TextareaElement(context) : super(context, isMultiline: true, defaultStyle: _defaultStyle, isReplacedElement: true);

  // Bindings.
  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'width':
        return width;
      case 'height':
        return height;
      case 'rows':
        return rows;
      case 'cols':
        return cols;
      case 'value':
        return value;
      case 'defaultValue':
        return defaultValue;
      case 'autocomplete':
        return autocomplete;
      case 'autofocus':
        return autofocus;
      case 'required':
        return required;
      case 'readonly':
        return readOnly;
      case 'name':
        return name;
      case 'disabled':
        return disabled;
      case 'minLength':
        return minLength;
      case 'maxLength':
        return maxLength;
      case 'placeholder':
        return placeholder;
      case 'inputMode':
        return inputMode;
      default:
        return super.getBindingProperty(key);
    }
  }

  @override
  void setBindingProperty(String key, val) {
    switch (key) {
      case 'width':
        width = castToType<num>(val).toInt();
        break;
      case 'height':
        height = castToType<num>(val).toInt();
        break;
      case 'rows':
        rows = castToType<num>(val).toInt();
        break;
      case 'cols':
        cols = castToType<num>(val).toInt();
        break;
      case 'value':
        value = castToType<String?>(val);
        break;
      case 'defaultValue':
        defaultValue = castToType<String?>(val);
        break;
      case 'autocomplete':
        autocomplete = castToType<String>(val);
        break;
      case 'autofocus':
        autofocus = castToType<bool>(val);
        break;
      case 'required':
        required = castToType<bool>(val);
        break;
      case 'readonly':
        readOnly = castToType<bool>(val);
        break;
      case 'name':
        name = castToType<String>(val);
        break;
      case 'disabled':
        disabled = castToType<bool>(val);
        break;
      case 'minLength':
        minLength = castToType<num>(val).toInt();
        break;
      case 'maxLength':
        maxLength = castToType<num>(val).toInt();
        break;
      case 'placeholder':
        placeholder = castToType<String>(val);
        break;
      case 'inputMode':
        inputMode = castToType<String>(val);
        break;
      default:
        super.setBindingProperty(key, value);
    }
  }

  @override
  invokeBindingMethod(String method, List args) {
    switch (method) {
      case 'focus':
        return focus();
      case 'blur':
        return blur();
      default:
        return super.invokeBindingMethod(method, args);
    }
  }

  @override
  void setAttribute(String qualifiedName, String val) {
    super.setAttribute(qualifiedName, val);
    switch (qualifiedName) {
      case 'width':
        width = attributeToProperty<int>(val);
        break;
      case 'height':
        height = attributeToProperty<int>(val);
        break;
      case 'rows':
        rows = attributeToProperty<int>(val);
        break;
      case 'cols':
        cols = attributeToProperty<int>(val);
        break;
      case 'value':
        defaultValue = attributeToProperty<String>(val);
        break;
      case 'autocomplete':
        autocomplete = attributeToProperty<String>(val);
        break;
      case 'autofocus':
        autofocus = attributeToProperty<bool>(val);
        break;
      case 'required':
        required = attributeToProperty<bool>(val);
        break;
      case 'readonly':
        readOnly = attributeToProperty<bool>(val);
        break;
      case 'name':
        name = attributeToProperty<String>(val);
        break;
      case 'disabled':
        disabled = attributeToProperty<bool>(val);
        break;
      case 'minlength':
        minLength = attributeToProperty<int>(val);
        break;
      case 'maxlength':
        maxLength = attributeToProperty<int>(val);
        break;
      case 'placeholder':
        placeholder = attributeToProperty<String>(val);
        break;
      case 'inputmode':
        inputMode = attributeToProperty<String>(val);
        break;
    }
  }

  // The children changed steps for textarea elements must, if the element's dirty value
  // flag is false, set the element's raw value to its child text content.
  // https://html.spec.whatwg.org/multipage/form-elements.html#the-textarea-element
  @override
  void childrenChanged() {
    defaultValue = textContent;
  }

  int get rows => int.tryParse(getAttribute('rows') ?? '') ?? 0;
  set rows(int value) {
    if (value < 0) value = 0;
    internalSetAttribute('rows', value.toString());
    _updateDefaultHeight();
  }

  int get cols => int.tryParse(getAttribute('cols') ?? '') ?? 0;
  set cols(int value) {
    if (value < 0) value = 0;
    internalSetAttribute('cols', value.toString());
    _updateDefaultWidth();
  }

  double? get _defaultWidth {
    // cols defaults to 20.
    // https://html.spec.whatwg.org/multipage/form-elements.html#attr-textarea-cols
    return avgCharWidth * double.parse(attributes[COLS] ?? '20');
  }

  double? get _defaultHeight {
    // rows defaults to 2.
    // https://html.spec.whatwg.org/multipage/form-elements.html#attr-textarea-rows
    double computedLineHeight =
        renderStyle.lineHeight != CSSLengthValue.normal ? renderStyle.lineHeight.computedValue : avgCharHeight;

    return computedLineHeight * double.parse(attributes[ROWS] ?? '2');
  }

  // The concatenation of the data of all the Text node descendants of node.
  // https://dom.spec.whatwg.org/#concept-descendant-text-content
  String get textContent {
    String str = '';
    // Set data of all text node children as value of textarea.
    for (Node child in childNodes) {
      if (child is TextNode) {
        str += child.data;
      }
    }
    return str;
  }

  // Width and height set through style.
  double? _styleWidth;
  double? _styleHeight;

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    style.addStyleChangeListener(_stylePropertyChanged);
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    _updateDefaultWidth();
    _updateDefaultHeight();
  }

  void _stylePropertyChanged(String property, String? original, String present) {
    if (property == WIDTH) {
      _styleWidth = renderStyle.width.isNotAuto ? renderStyle.width.computedValue : null;
      _updateDefaultWidth();
    } else if (property == HEIGHT) {
      _styleHeight = renderStyle.height.isNotAuto ? renderStyle.height.computedValue : null;
      _updateDefaultHeight();
    } else if (property == LINE_HEIGHT) {
      _updateDefaultHeight();
    } else if (property == FONT_SIZE) {
      _updateDefaultWidth();
      _updateDefaultHeight();
    }
  }

  void _updateDefaultWidth() {
    // Cols attribute is only valid when width in style is not set.
    if (_styleWidth == null) {
      renderStyle.width = CSSLengthValue(_defaultWidth, CSSLengthType.PX);
    }
  }

  void _updateDefaultHeight() {
    // Rows attribute is only valid when height in style is not set.
    if (_styleHeight == null) {
      renderStyle.height = CSSLengthValue(_defaultHeight, CSSLengthType.PX);
    }
  }
}
