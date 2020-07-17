import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:kraken/bridge.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

import 'manifest.dart';

const String BUNDLE_URL = 'KRAKEN_BUNDLE_URL';
const String BUNDLE_PATH = 'KRAKEN_BUNDLE_PATH';
const String ENABLE_DEBUG = 'KRAKEN_ENABLE_DEBUG';
const String ENABLE_PERFORMANCE_OVERLAY = 'KRAKEN_ENABLE_PERFORMANCE_OVERLAY';
const String DEFAULT_BUNDLE_PATH = 'assets/bundle.js';
const int ZIP_FILE_MAGIC_NUMBER = 0x04034b50;

String getBundleURLFromEnv() {
  return Platform.environment[BUNDLE_URL];
}

String getBundlePathFromEnv() {
  return Platform.environment[BUNDLE_PATH];
}

String _md5(Uint8List data) {
  Digest digest = md5.convert(data);
  return digest.toString();
}

abstract class KrakenBundle {
  KrakenBundle(this.url);

  // Unique resource locator.
  final Uri url;
  // JS Content
  String content;
  // JS line offset, default to 0.
  List<String> assets = [];
  int lineOffset = 0;
  // Kraken bundle manifest
  AppManifest manifest;

  bool isResolved = false;

  Future<void> resolve();

  static Future<KrakenBundle> getBundle(String path, {String contentOverride}) async {
    KrakenBundle bundle;
    if (contentOverride != null && contentOverride.isNotEmpty) {
      bundle = RawBundle(contentOverride, null);
    } else if (path == null) {
      path = DEFAULT_BUNDLE_PATH;
    }

    // Treat empty scheme as https.
    if (path.startsWith('//')) path = 'https' + path;

    Uri uri = Uri.parse(path);

    if (uri.isScheme('HTTP') || uri.isScheme('HTTPS')) {
      bundle = NetworkBundle(uri);
    } else {
      bundle = AssetsBundle(uri);
    }

    if (bundle != null) {
      await bundle.resolve();
    }

    return bundle;
  }

  Future<Directory> _getLocalBundleDirectory() async {
    // https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html
    // Each app will have it's unique support directory, if sandbox is off, app
    // will share a common support directory(eg: /Library/Application support/${bundleId}/ in macOS).
    Directory support = await getApplicationSupportDirectory();
    String localBundlePath = '${support.path}/Kraken/Applications';

    // Make sure directory exists.
    Directory localBundleDirectory = Directory(localBundlePath);
    if (!localBundleDirectory.existsSync()) {
      localBundleDirectory.createSync(recursive: true);
    }
    return localBundleDirectory;
  }

  Future<void> run(int contextId) async {
    if (!isResolved) await resolve();
    evaluateScripts(contextId, content, url.toString(), lineOffset);
  }
}

class RawBundle extends KrakenBundle {
  RawBundle(String content, Uri url)
      : assert(content != null),
        super(url) {
    this.content = content;
  }

  @override
  Future<void> resolve() async {
    isResolved = true;
  }
}

class NetworkBundle extends KrakenBundle with BundleMixin {
  // Unique identifier.
  String bundleId;
  NetworkBundle(Uri url)
      : assert(url != null),
        super(url);

  @override
  Future<void> resolve() async {
    NetworkAssetBundle bundle = NetworkAssetBundle(url);
    String absoluteURL = url.toString();
    ByteData data = await bundle.load(absoluteURL);
    Uint8List dataList = data.buffer.asUint8List();
    // Test is zip file.
    if (isZipFile(dataList)) {
      bundleId = _md5(dataList);
      Directory localBundleDirectory = await _getLocalBundleDirectory();
      await _unArchive(dataList, Directory(path.join(localBundleDirectory.path, bundleId)));
    } else {
      content = await _resolveStringFromData(data, absoluteURL);
    }

    isResolved = true;
  }
}

class AssetsBundle extends KrakenBundle with BundleMixin {
  AssetsBundle(Uri url)
      : assert(url != null),
        super(url);

  @override
  Future<void> resolve() async {
    // JSBundle get default bundle manifest.
    manifest = AppManifest();
    String localPath = url.toString();
    ByteData data = await rootBundle.load(localPath);
    Uint8List buffer = data.buffer.asUint8List();
    if (isZipFile(buffer)) {
      Directory localBundleDirectory = await _getLocalBundleDirectory();
      await _unArchive(buffer, Directory(path.join(localBundleDirectory.path, _md5(buffer))));
    } else {
      content = await _resolveStringFromData(data, localPath);
    }

    isResolved = true;
  }
}

mixin BundleMixin on KrakenBundle {
  static String _utf8decode(ByteData data) {
    return utf8.decode(data.buffer.asUint8List());
  }

  Future<String> _resolveStringFromData(ByteData data, String key) async {
    if (data == null) throw FlutterError('Unable to load asset: $key');
    if (data.lengthInBytes < 10 * 1024) {
      // 10KB takes about 3ms to parse on a Pixel 2 XL.
      // See: https://github.com/dart-lang/sdk/issues/31954
      return utf8.decode(data.buffer.asUint8List());
    }
    return compute(_utf8decode, data, debugLabel: 'UTF8 decode for "$key"');
  }

  Future<void> _unArchive(Uint8List data, Directory dest) async {
    Archive archive = ZipDecoder().decodeBytes(data.cast<int>());
    for (ArchiveFile file in archive) {
      String filename = file.name;
      if (file.isFile) {
        if (filename == 'index.js') {
          content = utf8.decode(file.content);
        } else if (filename == 'manifest.json') {
          try {
            Map<String, dynamic> manifestJson = jsonDecode(utf8.decode(file.content));
            manifest = AppManifest.fromJson(manifestJson);
          } catch (err, stack) {
            print('Failed to parse manifest.json');
            print('$err\n$stack');
          }
        } else {
          // Treat as assets.
          assets.add(filename);
          File(path.join(dest.path, filename))
            ..createSync(recursive: true)
            ..writeAsBytesSync(file.content);
        }
      } else {
        final dir = Directory(path.join(dest.path, filename));
        dir.create(recursive: true);
      }
    }

    if (content == null) {
      if (kReleaseMode) {
        content = '';
      } else {
        throw FlutterError('ZipBundle have no JS bundle.');
      }
    }
  }

  bool isZipFile(Uint8List buffer) {
    if (buffer.length < 4) return false;

    /// Read a 32-bit word from the buffer.
    final b1 = buffer[0] & 0xff;
    final b2 = buffer[1] & 0xff;
    final b3 = buffer[2] & 0xff;
    final b4 = buffer[3] & 0xff;
    int signature = (b4 << 24) | (b3 << 16) | (b2 << 8) | b1;
    return signature == ZIP_FILE_MAGIC_NUMBER;
  }
}
