/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/module.dart';

const String DEFAULT_URL = 'about:blank';
const String UTF_8 = 'utf-8';

final ContentType _cssContentType = ContentType('text', 'css', charset: UTF_8);
// MIME types suits JavaScript: https://mathiasbynens.be/demo/javascript-mime-type
final ContentType _javascriptContentType = ContentType('text', 'javascript', charset: UTF_8);
final ContentType _javascriptApplicationContentType = ContentType('application', 'javascript', charset: UTF_8);
final ContentType _xJavascriptContentType = ContentType('application', 'x-javascript', charset: UTF_8);
final ContentType _webfBc1ContentType = ContentType('application', 'vnd.webf.bc1');

const List<String> _supportedByteCodeVersions = ['1'];

bool _isSupportedBytecode(String mimeType, Uri? uri) {
  if (uri != null) {
    for (int i = 0; i < _supportedByteCodeVersions.length; i++) {
      if (mimeType.contains('application/vnd.webf.bc' + _supportedByteCodeVersions[i])) return true;
      // @NOTE: This is useful for most http server that did not recognize a .kbc1 file.
      // Simply treat some.kbc1 file as the bytecode.
      if (uri.path.endsWith('.kbc' + _supportedByteCodeVersions[i])) return true;
    }
  }
  return false;
}

// The default accept request header.
// The order is HTML -> KBC -> JavaScript.
String _acceptHeader() {
  String bc = _supportedByteCodeVersions.map((String v) => 'application/vnd.webf.bc$v').join(',');
  return 'text/html,$bc,application/javascript';
}

bool _isAssetsScheme(String path) {
  return path.startsWith('assets:');
}

bool _isFileScheme(String path) {
  return path.startsWith('file:');
}

bool _isHttpScheme(String path) {
  return path.startsWith('http:') || path.startsWith('https:');
}

bool _isDataScheme(String path) {
  return path.startsWith('data:');
}

bool _isDefaultUrl(String url) {
  return url == DEFAULT_URL;
}

void _failedToResolveBundle(String url) {
  throw FlutterError('Failed to resolve bundle for $url');
}

abstract class WebFBundle {
  WebFBundle(this.url);

  // Unique resource locator.
  final String url;

  // Uri parsed by uriParser, assigned after resolving.
  Uri? _uri;
  Uri? get resolvedUri => _uri;

  // The bundle data of raw.
  Uint8List? data;

  // Indicate the bundle is resolved.
  bool get isResolved => _uri != null && data != null;

  // Content type for data.
  // The default value is plain text.
  ContentType contentType = ContentType.text;

  @mustCallSuper
  Future<void> resolve(int? contextId) async {
    if (isResolved) return;

    // Source is input by user, do not trust it's a valid URL.
    _uri = Uri.tryParse(url);
    if (contextId != null && _uri != null) {
      WebFController? controller = WebFController.getControllerOfJSContextId(contextId);
      if (controller != null) {
        _uri = controller.uriParser!.resolve(Uri.parse(controller.url), _uri!);
      }
    }
  }

  // Dispose the memory obtained by bundle.
  @mustCallSuper
  void dispose() {
    data = null;
  }

  static WebFBundle fromUrl(String url, {Map<String, String>? additionalHttpHeaders}) {
    if (_isHttpScheme(url)) {
      return NetworkBundle(url, additionalHttpHeaders: additionalHttpHeaders);
    } else if (_isAssetsScheme(url)) {
      return AssetsBundle(url);
    } else if (_isFileScheme(url)) {
      return FileBundle(url);
    } else if (_isDataScheme(url)) {
      return DataBundle.fromDataUrl(url);
    } else if (_isDefaultUrl(url)) {
      return DataBundle.fromString('', url, contentType: _javascriptContentType);
    } else {
      throw FlutterError('Unsupported url. $url');
    }
  }

  static WebFBundle fromContent(String content, {String url = DEFAULT_URL}) {
    return DataBundle.fromString(content, url, contentType: _javascriptContentType);
  }

  static WebFBundle fromBytecode(Uint8List data, {String url = DEFAULT_URL}) {
    return DataBundle(data, url, contentType: _webfBc1ContentType);
  }

  bool get isHTML => contentType.mimeType == ContentType.html.mimeType;
  bool get isCSS => contentType.mimeType == _cssContentType.mimeType;
  bool get isJavascript =>
      contentType.mimeType == _javascriptContentType.mimeType ||
      contentType.mimeType == _javascriptApplicationContentType.mimeType ||
      contentType.mimeType == _xJavascriptContentType.mimeType;
  bool get isBytecode => _isSupportedBytecode(contentType.mimeType, _uri);
}

// The bundle that output input data.
class DataBundle extends WebFBundle {
  DataBundle(Uint8List data, String url, {ContentType? contentType}) : super(url) {
    this.data = data;
    this.contentType = contentType ?? ContentType.binary;
  }

  DataBundle.fromString(String content, String url, {ContentType? contentType}) : super(url) {
    // Encode string to data by utf8.
    data = Uint8List.fromList(utf8.encode(content));
    this.contentType = contentType ?? ContentType.text;
  }

  DataBundle.fromDataUrl(String dataUrl, {ContentType? contentType}) : super(dataUrl) {
    UriData uriData = UriData.parse(dataUrl);
    data = uriData.contentAsBytes();
    this.contentType = contentType ?? ContentType.parse('${uriData.mimeType}; charset=${uriData.charset}');
  }
}

// The bundle that source from http or https.
class NetworkBundle extends WebFBundle {
  // Do not access this field directly; use [_httpClient] instead.
  // We set `autoUncompress` to false to ensure that we can trust the value of
  // the `Content-CSSLength` HTTP header. We automatically uncompress the content
  // in our call to [consolidateHttpClientResponseBytes].
  static final HttpClient _sharedHttpClient = HttpClient()
    ..userAgent = NavigatorModule.getUserAgent()
    ..autoUncompress = false;

  NetworkBundle(String url, {this.additionalHttpHeaders}) : super(url);

  Map<String, String>? additionalHttpHeaders = {};

  @override
  Future<void> resolve(int? contextId) async {
    super.resolve(contextId);
    final HttpClientRequest request = await _sharedHttpClient.getUrl(_uri!);

    // Prepare request headers.
    request.headers.set('Accept', _acceptHeader());
    additionalHttpHeaders?.forEach(request.headers.set);
    if (contextId != null) {
      WebFHttpOverrides.setContextHeader(request.headers, contextId);
    }

    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Unable to load asset: $url'),
        IntProperty('HTTP status code', response.statusCode),
      ]);
    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    data = bytes.buffer.asUint8List();
    contentType = response.headers.contentType ?? ContentType.binary;
  }
}

class AssetsBundle extends WebFBundle with _ExtensionContentTypeResolver {
  AssetsBundle(String url) : super(url);

  @override
  Future<WebFBundle> resolve(int? contextId) async {
    super.resolve(contextId);
    final Uri? _resolvedUri = resolvedUri;
    if (_resolvedUri != null) {
      final String assetName = getAssetName(_resolvedUri);
      ByteData byteData = await rootBundle.load(assetName);
      data = byteData.buffer.asUint8List();
    } else {
      _failedToResolveBundle(url);
    }
    return this;
  }

  /// Get flutter asset name from uri scheme asset.
  ///   eg: assets:///foo/bar.html -> foo/bar.html
  ///       assets:foo/bar.html -> foo/bar.html
  static String getAssetName(Uri assetUri) {
    String assetName = assetUri.path;

    // Remove leading `/`.
    if (assetName.startsWith('/')) {
      assetName = assetName.substring(1);
    }
    return assetName;
  }
}

/// The bundle that source from local io.
class FileBundle extends WebFBundle with _ExtensionContentTypeResolver {
  FileBundle(String url) : super(url);

  @override
  Future<WebFBundle> resolve(int? contextId) async {
    super.resolve(contextId);

    Uri uri = _uri!;
    final String path = uri.path;
    File file = File(path);

    if (await file.exists()) {
      data = await file.readAsBytes();
    } else {
      _failedToResolveBundle(url);
    }
    return this;
  }
}

/// [_ExtensionContentTypeResolver] is useful for [WebFBundle] to determine
/// content-type by uri's extension.
mixin _ExtensionContentTypeResolver on WebFBundle {
  ContentType? _contentType;

  @override
  ContentType get contentType => _contentType ??= _resolveContentType(_uri);

  static ContentType _resolveContentType(Uri? uri) {
    if (_isUriExt(uri, '.js')) {
      return _javascriptApplicationContentType;
    } else if (_isUriExt(uri, '.html')) {
      return ContentType.html;
    } else if (_isSupportedBytecode('', uri)) {
      return _webfBc1ContentType;
    } else if (_isUriExt(uri, '.css')) {
      return _cssContentType;
    }
    return ContentType.text;
  }

  static bool _isUriExt(Uri? uri, String ext) {
    if (uri == null) {
      return false;
    }
    return uri.path.toLowerCase().endsWith(ext);
  }
}
