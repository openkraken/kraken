/*
 * Copyright (C) 2022-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/material.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/widget.dart';

class HTMLView extends StatefulWidget {
  final String data;

  HTMLView(this.data);

  @override
  HTMLViewState<HTMLView> createState() => HTMLViewState<HTMLView>(data);
}
