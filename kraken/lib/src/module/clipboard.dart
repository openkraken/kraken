import 'package:flutter/services.dart';
import 'package:kraken/src/module/module_manager.dart';

class KrakenClipboard extends BaseModule {
  KrakenClipboard(ModuleManager moduleManager) : super(moduleManager);

  static Future<String> readText() async {
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    return data.text;
  }

  static Future<void> writeText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  void dispose() {}

  @override
  String invoke(List params, callback) {
    String method = params[1];
    if (method == 'readText') {
      KrakenClipboard.readText().then((String value) {
        callback(value ?? '');
      }).catchError((e, stack) {
        callback('Error: $e\n$stack');
      });
    } else if (method == 'writeText') {
      List methodArgs = params[2];
      KrakenClipboard.writeText(methodArgs[0]).then((_) {
        callback('');
      }).catchError((e, stack) {
        callback('Error: $e\n$stack');
      });
    }
    return '';
  }
}
