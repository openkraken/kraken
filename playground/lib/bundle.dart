import 'dart:core';
import 'dart:io';
import 'dart:async';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

class BundleManager {

  Future<String> get defaultDownloadDirPath async {
    Directory tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/kraken/jsbundle';
  }

  Future<Response> _download(String url, String savePath, [String eTag]) async {
    Options options;
    if (eTag?.isNotEmpty == true) {
      options = Options(headers: {'If-None-Match': eTag});
    }
    return Dio().download(url, savePath, options: options);
  }

  void _unarchive(String zipPath, String destinationPath) async {
    List<int> bytes = await File(zipPath).readAsBytes();
    _unarchiveIntList(bytes, destinationPath);
  }

  void _unarchiveIntList(List<int> data, String destinationPath) async {
    Archive archive = ZipDecoder().decodeBytes(data);
    for (ArchiveFile file in archive) {
      String filename = file.name;
      if (file.isFile) {
        List<int> data = file.content;
        File(path.join(destinationPath, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        final dir = Directory(path.join(destinationPath, filename));
        // ignore: not_enough_required_arguments
        dir.create(recursive: true);
      }
    }
  }

  Future<String> downloadAndParse(String url) async {
    String downloadDirPath = await defaultDownloadDirPath;
    Directory downloadDir = Directory(downloadDirPath);
    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
    }
    String savePath = path.join(downloadDir.path, 'jsbundle.zip');
    Response response;
    File eTagFile = File(path.join(downloadDirPath, 'etag'));
    if (!File(savePath).existsSync()) {
      response = await _download(url, savePath);
    } else {
      String eTag;
      if (eTagFile.existsSync()) {
        eTag = await eTagFile.readAsString();
      }

      response = await _download(url, savePath, eTag);
    }
    if (response.statusCode == 200) {
      _unarchive(savePath, downloadDir.path);
      eTagFile.writeAsStringSync(response.headers.value('etag'));
    }
    // TODO miss json parse logic
    File readFile = File(
        path.join(downloadDir.path, 'build', 'kraken', 'index.js'));
    if (readFile.existsSync()) {
      return readFile.readAsString();
    } else {
      return Future<String>.value('');
    }
  }
}