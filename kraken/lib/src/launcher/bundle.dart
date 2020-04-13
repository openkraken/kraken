import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:kraken/bridge.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import 'manifest.dart';

const String BUNDLE_URL = 'KRAKEN_BUNDLE_URL';
const String BUNDLE_PATH = 'KRAKEN_BUNDLE_PATH';
const String ENABLE_DEBUG = 'KRAKEN_ENABLE_DEBUG';
const String ENABLE_PERFORMANCE_OVERLAY = 'KRAKEN_ENABLE_PERFORMANCE_OVERLAY';
const String DEFAULT_BUNDLE_PATH = 'assets/bundle';
// `kap` is Kraken App Package.
const String EXTENSION_KAP = '.kap';
const String EXTENSION_ZIP = '.zip';
const String EXTENSION_JS = '.js';

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
  final String url;
  // JS Content
  String content;
  // JS line offset, default to 0.
  List<String> assets = [];
  int lineOffset = 0;
  // Kraken bundle manifest
  AppManifest manifest;

  bool isResolved = false;

  Future<void> resolve();

  bool get isNetworkBundle {
    return url.startsWith('//') || url.startsWith('http');
  }

  /// Check path is a kap(zip) bundle.
  static bool isZipBundle(String url) {
    return url.endsWith(EXTENSION_KAP) || url.endsWith(EXTENSION_ZIP);
  }

  /// Check path is a JS bundle.
  static bool isJSBundle(String url) {
    return url.endsWith(EXTENSION_JS);
  }

  static Future<KrakenBundle> getBundle(String path, { String contentOverride }) async {
    KrakenBundle bundle;
    if (contentOverride != null && contentOverride.isNotEmpty) {
      bundle = RawBundle(contentOverride, 'RawContent');
    }

    if (path == null) return null;

    if (isZipBundle(path)) {
      bundle = ZipBundle(path);
    } else if (isJSBundle(path)) {
      bundle = JSBundle(path);
    }

    if (bundle != null) {
      await bundle.resolve();
      return bundle;
    } else {
      return null;
    }
  }

  Future<Directory> _getLocalBundleDirectory() async {
    // https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html
    // Each app will have it's unique support directory, if sandbox is off, app
    // will share a common support directory(eg: /Library/Application support/${bundleId}/ in macOS).
    Directory support = await getApplicationSupportDirectory();
    String localBundlePath = '${support.path}/Bundles';

    // Make sure directory exists.
    Directory localBundleDirectory = Directory(localBundlePath);
    if (!localBundleDirectory.existsSync()) {
      localBundleDirectory.createSync(recursive: true);
    }
    return localBundleDirectory;
  }

  Future<void> run() async {
    if (!isResolved) await resolve();
    evaluateScripts(content, url, lineOffset);
  }
}

class RawBundle extends KrakenBundle {
  RawBundle(String content, String url) : assert(content != null), super(url) {
    this.content = content;
  }

  @override
  Future<void> resolve() async {
    isResolved = true;
  }
}

class ZipBundle extends KrakenBundle {
  // Unique identifier.
  String bundleId;
  ZipBundle(String url) : assert(url != null), super(url);

  @override
  Future<void> resolve() async {
    ByteData data;
    if (isNetworkBundle) {
      Uri uri = Uri.parse(url);
      NetworkAssetBundle bundle = NetworkAssetBundle(uri);
      data = await bundle.load(uri.toString());
    } else {
      // File Bundle.
      data = await rootBundle.load(url);
    }

    Uint8List dataList = data.buffer.asUint8List();
    bundleId = _md5(dataList);

    Directory localBundleDirectory = await _getLocalBundleDirectory();
    await _unArchive(dataList, Directory(path.join(localBundleDirectory.path, bundleId)));

    isResolved = true;
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
          } catch(err, stack) {
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
        // @TODO: Recursive files.
        final dir = Directory(path.join(dest.path, filename));
        dir.create(recursive: true);
      }
    }
  }
}

class JSBundle extends KrakenBundle {
  JSBundle(String url) : assert(url != null), super(url);

  @override
  Future<void> resolve() async {
    // JSBundle get default bundle manifest.
    manifest = AppManifest();
    if (isNetworkBundle) {
      Response response = await Dio().get(url);
      content = response.toString();
    } else {
      content = await rootBundle.loadString(url);
    }

    isResolved = true;
  }
}
