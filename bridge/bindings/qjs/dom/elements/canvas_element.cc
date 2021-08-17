/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "canvas_element.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {
  CanvasRenderingContext2D::CanvasRenderingContext2D(JSContext *context,
                                                   NativeCanvasRenderingContext2D *nativePtr)
  : HostObject(context, "CanvasRenderingContext2D"), m_nativePtr(nativePtr) {
}
JSValue CanvasRenderingContext2D::callNativeMethods(const char *method, int32_t argc,
                                               NativeValue *argv) {
  if (m_nativePtr->callNativeMethods == nullptr) {
    return JS_ThrowTypeError(m_ctx, "Failed to call native dart methods: callNativeMethods not initialized.");
  }

  std::u16string methodString;
  fromUTF8(method, methodString);

  NativeString m{
    reinterpret_cast<const uint16_t *>(methodString.c_str()),
    static_cast<int32_t>(methodString.size())
  };

  NativeValue nativeValue{};
  m_nativePtr->callNativeMethods(m_nativePtr, &nativeValue, &m, argc, argv);
  JSValue returnValue = nativeValueToJSValue(m_context, nativeValue);
  return returnValue;
}
PROP_GETTER(CanvasRenderingContext2D, fillStyle)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getFillStyle", 0, nullptr);
}
PROP_SETTER(CanvasRenderingContext2D, fillStyle)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setFillStyle", 1, arguments);
}
PROP_GETTER(CanvasRenderingContext2D, direction)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getDirection", 0, nullptr);
}
PROP_SETTER(CanvasRenderingContext2D, direction)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setDirection", 1, arguments);
}
PROP_GETTER(CanvasRenderingContext2D, font)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getFont", 0, nullptr);
}
PROP_SETTER(CanvasRenderingContext2D, font)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setFont", 1, arguments);
}
PROP_GETTER(CanvasRenderingContext2D, strokeStyle)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getStrokeStyle", 0, nullptr);
}
PROP_SETTER(CanvasRenderingContext2D, strokeStyle)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setStrokeStyle", 1, arguments);
}
PROP_GETTER(CanvasRenderingContext2D, lineCap)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getLineCap", 0, nullptr);
}
PROP_SETTER(CanvasRenderingContext2D, lineCap)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setLineCap", 1, arguments);
}
PROP_GETTER(CanvasRenderingContext2D, lineDashOffset)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getLineDashOffset", 0, nullptr);
}
PROP_SETTER(CanvasRenderingContext2D, lineDashOffset)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setLineDashOffset", 1, arguments);
}
PROP_GETTER(CanvasRenderingContext2D, lineJoin)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getLineJoin", 0, nullptr);
}
PROP_SETTER(CanvasRenderingContext2D, lineJoin)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setLineJoin", 1, arguments);
}
PROP_GETTER(CanvasRenderingContext2D, lineWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getLineWidth", 0, nullptr);
}
PROP_SETTER(CanvasRenderingContext2D, lineWidth)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setLineWidth", 1, arguments);
}
PROP_GETTER(CanvasRenderingContext2D, miterLimit)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getMiterLimit", 0, nullptr);
}
PROP_SETTER(CanvasRenderingContext2D, miterLimit)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setMiterLimit", 1, arguments);
}
PROP_GETTER(CanvasRenderingContext2D, textAlign)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getTextAlign", 0, nullptr);
}
PROP_SETTER(CanvasRenderingContext2D, textAlign)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setTextAlign", 1, arguments);
}
PROP_GETTER(CanvasRenderingContext2D, textBaseline)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getTextBaseline", 0, nullptr);
}
PROP_SETTER(CanvasRenderingContext2D, textBaseline)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setTextBaseline", 1, arguments);
}
JSValue CanvasRenderingContext2D::arc(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 5) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'arc' on 'CanvasRenderingContext2D': 5 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute arc: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute arc: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute arc: 3st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[3])) {
    return JS_ThrowTypeError(ctx, "Failed to execute arc: 4st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[4])) {
    return JS_ThrowTypeError(ctx, "Failed to execute arc: 5st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3]),
   jsValueToNativeValue(ctx, argv[4]),
   jsValueToNativeValue(ctx, argv[5])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("arc", 6, arguments);
}
JSValue CanvasRenderingContext2D::arcTo(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 5) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'arcTo' on 'CanvasRenderingContext2D': 5 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute arcTo: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute arcTo: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute arcTo: 3st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[3])) {
    return JS_ThrowTypeError(ctx, "Failed to execute arcTo: 4st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[4])) {
    return JS_ThrowTypeError(ctx, "Failed to execute arcTo: 5st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3]),
   jsValueToNativeValue(ctx, argv[4])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("arcTo", 5, arguments);
}
JSValue CanvasRenderingContext2D::beginPath(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {

  getDartMethod()->flushUICommand();

  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("beginPath", 0, nullptr);
}
JSValue CanvasRenderingContext2D::bezierCurveTo(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 6) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'bezierCurveTo' on 'CanvasRenderingContext2D': 6 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute bezierCurveTo: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute bezierCurveTo: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute bezierCurveTo: 3st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[3])) {
    return JS_ThrowTypeError(ctx, "Failed to execute bezierCurveTo: 4st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[4])) {
    return JS_ThrowTypeError(ctx, "Failed to execute bezierCurveTo: 5st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[5])) {
    return JS_ThrowTypeError(ctx, "Failed to execute bezierCurveTo: 6st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3]),
   jsValueToNativeValue(ctx, argv[4]),
   jsValueToNativeValue(ctx, argv[5])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("bezierCurveTo", 6, arguments);
}
JSValue CanvasRenderingContext2D::clearRect(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 4) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'clearRect' on 'CanvasRenderingContext2D': 4 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute clearRect: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute clearRect: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute clearRect: 3st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[3])) {
    return JS_ThrowTypeError(ctx, "Failed to execute clearRect: 4st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("clearRect", 4, arguments);
}
JSValue CanvasRenderingContext2D::closePath(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {

  getDartMethod()->flushUICommand();

  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("closePath", 0, nullptr);
}
JSValue CanvasRenderingContext2D::clip(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'clip' on 'CanvasRenderingContext2D': 1 argument required, but %d present.", argc);
  }
  if (!JS_IsString(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute clip: 1st arguments is not String.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("clip", 1, arguments);
}
JSValue CanvasRenderingContext2D::drawImage(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  switch(argc) {
    case 9: {
      if (argc < 9) {
        return JS_ThrowTypeError(ctx, "Failed to execute 'drawImage' on 'CanvasRenderingContext2D': 9 argument required, but %d present.", argc);
      }
      
      if (!JS_IsNumber(argv[1])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 2st arguments is not Number.");
      }
      if (!JS_IsNumber(argv[2])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 3st arguments is not Number.");
      }
      if (!JS_IsNumber(argv[3])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 4st arguments is not Number.");
      }
      if (!JS_IsNumber(argv[4])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 5st arguments is not Number.");
      }
      if (!JS_IsNumber(argv[5])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 6st arguments is not Number.");
      }
      if (!JS_IsNumber(argv[6])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 7st arguments is not Number.");
      }
      if (!JS_IsNumber(argv[7])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 8st arguments is not Number.");
      }
      if (!JS_IsNumber(argv[8])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 9st arguments is not Number.");
      }
    
      getDartMethod()->flushUICommand();
    NativeValue arguments[] = {
       jsValueToNativeValue(ctx, argv[0]),
       jsValueToNativeValue(ctx, argv[1]),
       jsValueToNativeValue(ctx, argv[2]),
       jsValueToNativeValue(ctx, argv[3]),
       jsValueToNativeValue(ctx, argv[4]),
       jsValueToNativeValue(ctx, argv[5]),
       jsValueToNativeValue(ctx, argv[6]),
       jsValueToNativeValue(ctx, argv[7]),
       jsValueToNativeValue(ctx, argv[8])
      };
      auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
      return element->callNativeMethods("drawImage", 9, arguments);
    }
    case 5: {
      if (argc < 5) {
        return JS_ThrowTypeError(ctx, "Failed to execute 'drawImage' on 'CanvasRenderingContext2D': 5 argument required, but %d present.", argc);
      }
      
      if (!JS_IsNumber(argv[1])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 2st arguments is not Number.");
      }
      if (!JS_IsNumber(argv[2])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 3st arguments is not Number.");
      }
      if (!JS_IsNumber(argv[3])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 4st arguments is not Number.");
      }
      if (!JS_IsNumber(argv[4])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 5st arguments is not Number.");
      }
    
      getDartMethod()->flushUICommand();
    NativeValue arguments[] = {
       jsValueToNativeValue(ctx, argv[0]),
       jsValueToNativeValue(ctx, argv[1]),
       jsValueToNativeValue(ctx, argv[2]),
       jsValueToNativeValue(ctx, argv[3]),
       jsValueToNativeValue(ctx, argv[4])
      };
      auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
      return element->callNativeMethods("drawImage", 5, arguments);
    }
    case 3: {
      if (argc < 3) {
        return JS_ThrowTypeError(ctx, "Failed to execute 'drawImage' on 'CanvasRenderingContext2D': 3 argument required, but %d present.", argc);
      }
      
      if (!JS_IsNumber(argv[1])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 2st arguments is not Number.");
      }
      if (!JS_IsNumber(argv[2])) {
        return JS_ThrowTypeError(ctx, "Failed to execute drawImage: 3st arguments is not Number.");
      }
    
      getDartMethod()->flushUICommand();
    NativeValue arguments[] = {
       jsValueToNativeValue(ctx, argv[0]),
       jsValueToNativeValue(ctx, argv[1]),
       jsValueToNativeValue(ctx, argv[2])
      };
      auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
      return element->callNativeMethods("drawImage", 3, arguments);
    }
    
  default:
    return JS_NULL;
  }
}
JSValue CanvasRenderingContext2D::ellipse(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 7) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'ellipse' on 'CanvasRenderingContext2D': 7 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ellipse: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ellipse: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ellipse: 3st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[3])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ellipse: 4st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[4])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ellipse: 5st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[5])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ellipse: 6st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[6])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ellipse: 7st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3]),
   jsValueToNativeValue(ctx, argv[4]),
   jsValueToNativeValue(ctx, argv[5]),
   jsValueToNativeValue(ctx, argv[6]),
   jsValueToNativeValue(ctx, argv[7])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("ellipse", 8, arguments);
}
JSValue CanvasRenderingContext2D::fill(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'fill' on 'CanvasRenderingContext2D': 1 argument required, but %d present.", argc);
  }
  if (!JS_IsString(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute fill: 1st arguments is not String.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("fill", 1, arguments);
}
JSValue CanvasRenderingContext2D::fillRect(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 4) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'fillRect' on 'CanvasRenderingContext2D': 4 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute fillRect: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute fillRect: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute fillRect: 3st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[3])) {
    return JS_ThrowTypeError(ctx, "Failed to execute fillRect: 4st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("fillRect", 4, arguments);
}
JSValue CanvasRenderingContext2D::fillText(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 3) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'fillText' on 'CanvasRenderingContext2D': 3 argument required, but %d present.", argc);
  }
  if (!JS_IsString(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute fillText: 1st arguments is not String.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute fillText: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute fillText: 3st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("fillText", 4, arguments);
}
JSValue CanvasRenderingContext2D::lineTo(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'lineTo' on 'CanvasRenderingContext2D': 2 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute lineTo: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute lineTo: 2st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("lineTo", 2, arguments);
}
JSValue CanvasRenderingContext2D::moveTo(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'moveTo' on 'CanvasRenderingContext2D': 2 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute moveTo: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute moveTo: 2st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("moveTo", 2, arguments);
}
JSValue CanvasRenderingContext2D::rect(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 4) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'rect' on 'CanvasRenderingContext2D': 4 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute rect: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute rect: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute rect: 3st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[3])) {
    return JS_ThrowTypeError(ctx, "Failed to execute rect: 4st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("rect", 4, arguments);
}
JSValue CanvasRenderingContext2D::restore(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {

  getDartMethod()->flushUICommand();

  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("restore", 0, nullptr);
}
JSValue CanvasRenderingContext2D::resetTransform(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {

  getDartMethod()->flushUICommand();

  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("resetTransform", 0, nullptr);
}
JSValue CanvasRenderingContext2D::rotate(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'rotate' on 'CanvasRenderingContext2D': 1 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute rotate: 1st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("rotate", 1, arguments);
}
JSValue CanvasRenderingContext2D::quadraticCurveTo(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 4) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'quadraticCurveTo' on 'CanvasRenderingContext2D': 4 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute quadraticCurveTo: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute quadraticCurveTo: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute quadraticCurveTo: 3st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[3])) {
    return JS_ThrowTypeError(ctx, "Failed to execute quadraticCurveTo: 4st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("quadraticCurveTo", 4, arguments);
}
JSValue CanvasRenderingContext2D::stroke(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {

  getDartMethod()->flushUICommand();

  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("stroke", 0, nullptr);
}
JSValue CanvasRenderingContext2D::strokeRect(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 4) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'strokeRect' on 'CanvasRenderingContext2D': 4 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute strokeRect: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute strokeRect: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute strokeRect: 3st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[3])) {
    return JS_ThrowTypeError(ctx, "Failed to execute strokeRect: 4st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("strokeRect", 4, arguments);
}
JSValue CanvasRenderingContext2D::save(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {

  getDartMethod()->flushUICommand();

  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("save", 0, nullptr);
}
JSValue CanvasRenderingContext2D::scale(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'scale' on 'CanvasRenderingContext2D': 2 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute scale: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute scale: 2st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("scale", 2, arguments);
}
JSValue CanvasRenderingContext2D::strokeText(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 3) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'strokeText' on 'CanvasRenderingContext2D': 3 argument required, but %d present.", argc);
  }
  if (!JS_IsString(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute strokeText: 1st arguments is not String.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute strokeText: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute strokeText: 3st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("strokeText", 4, arguments);
}
JSValue CanvasRenderingContext2D::setTransform(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 6) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'setTransform' on 'CanvasRenderingContext2D': 6 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute setTransform: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute setTransform: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute setTransform: 3st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[3])) {
    return JS_ThrowTypeError(ctx, "Failed to execute setTransform: 4st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[4])) {
    return JS_ThrowTypeError(ctx, "Failed to execute setTransform: 5st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[5])) {
    return JS_ThrowTypeError(ctx, "Failed to execute setTransform: 6st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3]),
   jsValueToNativeValue(ctx, argv[4]),
   jsValueToNativeValue(ctx, argv[5])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("setTransform", 6, arguments);
}
JSValue CanvasRenderingContext2D::transform(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 6) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'transform' on 'CanvasRenderingContext2D': 6 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute transform: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute transform: 2st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[2])) {
    return JS_ThrowTypeError(ctx, "Failed to execute transform: 3st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[3])) {
    return JS_ThrowTypeError(ctx, "Failed to execute transform: 4st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[4])) {
    return JS_ThrowTypeError(ctx, "Failed to execute transform: 5st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[5])) {
    return JS_ThrowTypeError(ctx, "Failed to execute transform: 6st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1]),
   jsValueToNativeValue(ctx, argv[2]),
   jsValueToNativeValue(ctx, argv[3]),
   jsValueToNativeValue(ctx, argv[4]),
   jsValueToNativeValue(ctx, argv[5])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("transform", 6, arguments);
}
JSValue CanvasRenderingContext2D::translate(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'translate' on 'CanvasRenderingContext2D': 2 argument required, but %d present.", argc);
  }
  if (!JS_IsNumber(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute translate: 1st arguments is not Number.");
  }
  if (!JS_IsNumber(argv[1])) {
    return JS_ThrowTypeError(ctx, "Failed to execute translate: 2st arguments is not Number.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0]),
   jsValueToNativeValue(ctx, argv[1])
  };
  auto *element = static_cast<CanvasRenderingContext2D *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("translate", 2, arguments);
}

CanvasElement::CanvasElement(JSContext *context) : Element(context) {}

OBJECT_INSTANCE_IMPL(CanvasElement);

JSValue CanvasElement::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}
PROP_GETTER(CanvasElementInstance, width)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getWidth", 0, nullptr);
}
PROP_SETTER(CanvasElementInstance, width)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setWidth", 1, arguments);
}
PROP_GETTER(CanvasElementInstance, height)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<CanvasElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getHeight", 0, nullptr);
}
PROP_SETTER(CanvasElementInstance, height)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<CanvasElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("setHeight", 1, arguments);
}
JSValue CanvasElement::getContext(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'getContext' on 'CanvasElement': 1 argument required, but %d present.", argc);
  }
  if (!JS_IsString(argv[0])) {
    return JS_ThrowTypeError(ctx, "Failed to execute getContext: 1st arguments is not String.");
  }

  getDartMethod()->flushUICommand();
NativeValue arguments[] = {
   jsValueToNativeValue(ctx, argv[0])
  };
  auto *element = static_cast<CanvasElementInstance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("getContext", 1, arguments);
}
CanvasElementInstance::CanvasElementInstance(CanvasElement *element): ElementInstance(element, "CanvasElement", true) {}

}