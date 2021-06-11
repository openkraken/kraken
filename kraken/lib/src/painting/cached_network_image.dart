

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class CachedNetworkImage extends ImageProvider<CachedNetworkImage> {
  const CachedNetworkImage(this.url, {this.scale = 1.0, this.headers});

  final String url;

  final double scale;

  final Map<String, String>? headers;

  // Do not access this field directly; use [_httpClient] instead.
  // We set `autoUncompress` to false to ensure that we can trust the value of
  // the `Content-CSSLength` HTTP header. We automatically uncompress the content
  // in our call to [consolidateHttpClientResponseBytes].
  static final HttpClient _sharedHttpClient = HttpClient()..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null) client = debugNetworkImageHttpClientProvider!();
      return true;
    }());
    return client;
  }

  Future<Uri> _getTempDir() async {
    final Directory temp = await getTemporaryDirectory();
    return Uri.parse(temp.path);
  }

  Future<Uint8List> loadFile(CachedNetworkImage key, StreamController<ImageChunkEvent> chunkEvents) async {
    // Cached file path
    var tempDir = await _getTempDir();
    var tempFile = Uri.parse(tempDir.path + '/kraken/' + Uri.parse(url).hashCode.toString());
    final File file = File(tempFile.path);
    Uint8List? bytes;
    bool fileExisted = await file.exists();
    // Check cached file is existed
    if (fileExisted) {
      int fileLength = await file.length();
      if (fileLength > 0) {
        bytes = await file.readAsBytes();
      }
    }
    // Fallback to network
    if (bytes == null) {
      bytes = await fetchFile(key, chunkEvents);
      // Async store file
      storeFile(tempFile, bytes);
    }

    return bytes;
  }

  void storeFile(Uri tempFile, Uint8List bytes) async {
    try {
      File file = await File(tempFile.path).create(recursive: true);
      file.writeAsBytes(bytes);
    } catch (e) {}
  }

  Future<Codec?> _loadImage(
      CachedNetworkImage key, DecoderCallback decode, StreamController<ImageChunkEvent> chunkEvents) async {
    Uint8List bytes = await loadFile(key, chunkEvents);

    if (bytes.length > 0) {
      return decode(bytes);
    }
    return null;
  }

  Future<Uint8List> fetchFile(CachedNetworkImage key, StreamController<ImageChunkEvent> chunkEvents) async {
    try {
      final Uri resolved = Uri.base.resolve(key.url);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok)
        throw NetworkImageLoadException(statusCode: response.statusCode, uri: resolved);

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int? total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );
      if (bytes.lengthInBytes == 0) throw Exception('Image from network is an empty file: $resolved');

      return bytes;
    } finally {
      chunkEvents.close();
    }
  }

  @override
  Future<CachedNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedNetworkImage>(this);
  }

  @override
  ImageStreamCompleter load(CachedNetworkImage key, DecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
        codec: _loadImage(key, decode, chunkEvents).then((value) => value!),
        chunkEvents: chunkEvents.stream,
        scale: key.scale,
        informationCollector: () {
          return <DiagnosticsNode>[
            DiagnosticsProperty<ImageProvider>('Image provider', this),
            DiagnosticsProperty<CachedNetworkImage>('Image key', key),
          ];
        });
  }
}
