import 'platform.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

typedef Native_EvaluateScripts = Void Function(
    Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef Dart_EvaluateScripts = void Function(Pointer<Utf8>, Pointer<Utf8>, int);

typedef Native_InitJSEngine = Void Function();
typedef Dart_InitJSEngine = void Function();

final Dart_EvaluateScripts _evaluateScripts = nativeDynamicLibrary
    .lookup<NativeFunction<Native_EvaluateScripts>>('evaluateScripts')
    .asFunction();

final Dart_InitJSEngine _initJsEngine = nativeDynamicLibrary
    .lookup<NativeFunction<Native_InitJSEngine>>('initJsEngine')
    .asFunction();

void evaluateScripts(String code, String url, int line) {
  Pointer<Utf8> _code = Utf8.toUtf8(code);
  Pointer<Utf8> _url = Utf8.toUtf8(url);
  print('evaluate code $code');
  _evaluateScripts(_code, _url, line);
}

void initJSEngine() {
  _initJsEngine();
}
