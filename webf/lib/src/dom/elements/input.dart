/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'package:kraken/foundation.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';

const String INPUT = 'INPUT';
const String SIZE = 'size';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  BORDER: '1px solid #767676',
};

class InputElement extends TextFormControlElement {
  InputElement(context)
    : super(context, defaultStyle: _defaultStyle, isReplacedElement: true);

  // Bindings.
  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'width': return width;
      case 'height': return height;
      case 'size': return size;
      case 'value': return value;
      case 'defaultValue': return defaultValue;
      case 'accept': return accept;
      case 'autocomplete': return autocomplete;
      case 'autofocus': return autofocus;
      case 'required': return required;
      case 'readonly': return readOnly;
      case 'pattern': return pattern;
      case 'step': return step;
      case 'name': return name;
      case 'multiple': return multiple;
      case 'checked': return checked;
      case 'disabled': return disabled;
      case 'min': return min;
      case 'max': return max;
      case 'minLength': return minLength;
      case 'maxLength': return maxLength;
      case 'placeholder': return placeholder;
      case 'type': return type;
      case 'inputMode': return inputMode;
      default: return super.getBindingProperty(key);
    }
  }

  @override
  void setBindingProperty(String key, val) {
    switch (key) {
      case 'width': width = castToType<num>(val).toInt(); break;
      case 'height': height = castToType<num>(val).toInt(); break;
      case 'size': size = castToType<num>(val).toInt(); break;
      case 'value': value = castToType<String?>(val); break;
      case 'defaultValue': defaultValue = castToType<String?>(val); break;
      case 'accept': accept = castToType<String>(val); break;
      case 'autocomplete': autocomplete = castToType<String>(val); break;
      case 'autofocus': autofocus = castToType<bool>(val); break;
      case 'required': required = castToType<bool>(val); break;
      case 'readonly': readOnly = castToType<bool>(val); break;
      case 'pattern': pattern = castToType<String>(val); break;
      case 'step': step = castToType<String>(val); break;
      case 'name': name = castToType<String>(val); break;
      case 'multiple': multiple = castToType<bool>(val); break;
      case 'checked': checked = castToType<bool>(val); break;
      case 'disabled': disabled = castToType<bool>(val); break;
      case 'min': min = castToType<String>(val); break;
      case 'max': max = castToType<String>(val); break;
      case 'minLength': minLength = castToType<num>(val).toInt(); break;
      case 'maxLength': maxLength = castToType<num>(val).toInt(); break;
      case 'placeholder': placeholder = castToType<String>(val); break;
      case 'type': type = castToType<String>(val); break;
      case 'inputMode': inputMode = castToType<String>(val); break;
      default: super.setBindingProperty(key, value);
    }
  }

  @override
  invokeBindingMethod(String method, List args) {
    switch (method) {
      case 'focus': return focus();
      case 'blur': return blur();
      default: return super.invokeBindingMethod(method, args);
    }
  }

  @override
  void setAttribute(String qualifiedName, String val) {
    super.setAttribute(qualifiedName, val);
    switch (qualifiedName) {
      case 'width': width = attributeToProperty<int>(val); break;
      case 'height': height = attributeToProperty<int>(val); break;
      case 'size': size = attributeToProperty<int>(val); break;
      case 'value': defaultValue = attributeToProperty<String>(val); break;
      case 'accept': accept = attributeToProperty<String>(val); break;
      case 'autocomplete': autocomplete = attributeToProperty<String>(val); break;
      case 'autofocus': autofocus = attributeToProperty<bool>(val); break;
      case 'required': required = attributeToProperty<bool>(val); break;
      case 'readonly': readOnly = attributeToProperty<bool>(val); break;
      case 'pattern': pattern = attributeToProperty<String>(val); break;
      case 'step': step = attributeToProperty<String>(val); break;
      case 'name': name = attributeToProperty<String>(val); break;
      case 'multiple': multiple = attributeToProperty<bool>(val); break;
      case 'checked': checked = attributeToProperty<bool>(val); break;
      case 'disabled': disabled = attributeToProperty<bool>(val); break;
      case 'min': min = attributeToProperty<String>(val); break;
      case 'max': max = attributeToProperty<String>(val); break;
      case 'minlength': minLength = attributeToProperty<int>(val); break;
      case 'maxlength': maxLength = attributeToProperty<int>(val); break;
      case 'placeholder': placeholder = attributeToProperty<String>(val); break;
      case 'type': type = attributeToProperty<String>(val); break;
      case 'inputmode': inputMode = attributeToProperty<String>(val); break;
    }
  }

  int get size => int.tryParse(getAttribute('size') ?? '') ?? 0;
  set size(int value) {
    if (value < 0) value = 0;
    internalSetAttribute('size', value.toString());
    _updateDefaultWidth();
  }

  double? get _defaultWidth {
    // size defaults to 20.
    // https://html.spec.whatwg.org/multipage/input.html#attr-input-size
    return avgCharWidth * double.parse(attributes[SIZE] ?? '20');
  }

  // Width set through style.
  double? _styleWidth;

  @override
  void willAttachRenderer() {
    super.willAttachRenderer();
    style.addStyleChangeListener(_stylePropertyChanged);
  }

  @override
  void didAttachRenderer() {
    super.didAttachRenderer();
    _updateDefaultWidth();
  }

  void _stylePropertyChanged(String property, String? original, String present) {
    if (property == WIDTH) {
      _styleWidth = renderStyle.width.isNotAuto ? renderStyle.width.computedValue : null;
      _updateDefaultWidth();
    } else if (property == LINE_HEIGHT) {
      // Need to mark RenderTextControlLeaderLayer as needsLayout manually cause
      // line-height change will not affect constraints which will in turn
      // make RenderTextControlLeaderLayer jump layout.
      if (isRendererAttached && renderTextControlLeaderLayer != null) {
        renderTextControlLeaderLayer!.markNeedsLayout();
      }
    } else if (property == FONT_SIZE) {
      _updateDefaultWidth();
    }
  }

  void _updateDefaultWidth() {
    // cols is only valid when width in style is not set.
    if (_styleWidth == null) {
      renderStyle.width = CSSLengthValue(_defaultWidth, CSSLengthType.PX);
    }
  }
}

