/*
 * Copyright (C) 2022-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/material.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/widget.dart';

class HTMLView extends StatelessWidget {
  final String data;

  HTMLView(
    this.data,
  );

  @override
  Widget build(BuildContext context) {
    return Kraken(
      bundle: KrakenBundle.fromContent(data),
    );
  }
}
