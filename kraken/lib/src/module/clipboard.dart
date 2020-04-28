import 'package:flutter/services.dart';

class KrakenClipboard {
  static Future<String> readText() async {
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    return data.text;
  }

  static Future<void> writeText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
