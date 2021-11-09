import 'dart:math';

// https://www.w3.org/TR/trace-context/
// The traceparent header represents the incoming request in a tracing
// system in a common format, understood by all vendors like.
// Here’s an example of a traceparent header.
//    traceparent: 00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01
const String HttpHeaderTraceParent = 'traceparent';
// The current specification assumes the version is set to 00.
const String _TraceParentVersion = '00';
// The current version of this specification (00) only supports a single flag called sampled.
const String _TraceParentFlags = '00'; // not sampled

String genTraceParent() {
  // version-traceId-parentId-traceFlags
  return '$_TraceParentVersion-${genTraceId()}-${_genParentId()}-$_TraceParentFlags';
}

String genTraceId() {
  // 32HEXDIGLC: 2 + 11 + 19
  return '00' + DateTime.now().millisecondsSinceEpoch.toRadixString(16) + _getRandomId(19);
}

String _genParentId() {
  // 16HEXDIGLC: 2 + 14
  return '00' + _getRandomId(14);
}

final Random _random = Random.secure();
const String _chars = '0123456789abcdefghijklmnopqlstuvwxyz';
const int _length = _chars.length;

String _getRandomId(int size) {
  String id = '';
  while (0 < size--) {
    id += _chars[_random.nextInt(_length)];
  }
  return id;
}
