import 'package:kraken/widget.dart';
import 'package:flutter/material.dart';

void defineKrakenCustomElements() {
  Kraken.defineCustomElement('flutter-text', (Map<String, dynamic> properties) {
    return Text(properties['value'] ?? '', textDirection: TextDirection.ltr, style: TextStyle(color: Color.fromARGB(255, 100, 100, 100)));
  });

  Kraken.defineCustomElement('flutter-asset-image', (Map<String, dynamic> properties) {
    return Image(image: AssetImage(properties['src']));
  });
}
