/*
 * Copyright (C) 2022-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'package:flutter/material.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/widget.dart';

class HTMLViewState extends KrakenState<HTMLView> {
  final String html;

  HTMLViewState(this.html);

  @override
  Widget build(BuildContext context) {
    // print('context.widget=${context.widget}');
    return RepaintBoundary(
        child: FocusableActionDetector(
            actions: actionMap,
            focusNode: focusNode,
            onFocusChange: handleFocusChange,
            // TODO: _HTMLViewRenderObjectWidget
            child: Text(html),
            // child: _KrakenRenderObjectWidget(
            //   context.widget as HTMLView,
            //   widgetDelegate,
            // )
        )
    );
  }
}

class HTMLView extends StatefulWidget {
  final String data;

  HTMLView(this.data);

  @override
  HTMLViewState createState() => HTMLViewState(data);
}
