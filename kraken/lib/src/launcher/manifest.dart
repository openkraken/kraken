/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

// https://w3c.github.io/manifest/
class AppManifest with KrakenManifest {
  String? name;
  String? shortName;
  String? version;
  String? startUrl;
  String? display;
  String? backgroundColor;
  String? description;
  List<Icons>? icons;
  List<RelatedApplications>? relatedApplications;

  AppManifest({
    this.name,
    this.shortName,
    this.version,
    this.startUrl,
    this.display,
    this.backgroundColor,
    this.description,
    this.icons,
    this.relatedApplications,
  });

  AppManifest.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    shortName = json['short_name'];
    version = json['version'];
    startUrl = json['start_url'];
    display = json['display'];
    backgroundColor = json['background_color'];
    description = json['description'];
    if (json['icons'] != null) {
      icons = List<Icons>.empty(growable: true);
      json['icons'].forEach((Map<String, dynamic> v) {
        icons!.add(Icons.fromJson(v));
      });
    }
    if (json['related_applications'] != null) {
      relatedApplications = List<RelatedApplications>.empty(growable: true);
      json['related_applications'].forEach((Map<String, dynamic> v) {
        relatedApplications!.add(RelatedApplications.fromJson(v));
      });
    }
    _parseKrakenManifestFromJson(json);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['short_name'] = shortName;
    data['version'] = version;
    data['start_url'] = startUrl;
    data['display'] = display;
    data['background_color'] = backgroundColor;
    data['description'] = description;
    if (icons != null) {
      data['icons'] = icons!.map((v) => v.toJson()).toList();
    }
    if (relatedApplications != null) {
      data['related_applications'] = relatedApplications!.map((v) => v.toJson()).toList();
    }

    _appendKrakenJson(data);

    return data;
  }
}

/// The extra definition of AppManifest, only works in kraken.
mixin KrakenManifest {
  /// Description of window size.
  Size? size;

  /// Description of window title.
  String? title;

  /// Description of window can be resized.
  bool? resizeable;

  void _parseKrakenManifestFromJson(Map<String, dynamic> json) {
    title = json['title'];

    Map? rawSize = json['size'];
    if (rawSize != null) {
      size = Size(rawSize['width'] ?? 0, rawSize['height'] ?? 0);
    }

    var _resizeable = json['resizeable'];
    if (_resizeable is String)
      resizeable = _resizeable == 'true';
    else if (_resizeable is bool) resizeable = _resizeable;
  }

  void _appendKrakenJson(Map<String, dynamic> data) {
    Map<String, double> _size = {'width': size!.width, 'height': size!.height};
    data['size'] = _size;
    data['title'] = title;
    data['resizeable'] = resizeable;
  }
}

class Icons {
  String? src;
  String? sizes;
  String? type;

  Icons({this.src, this.sizes, this.type});

  Icons.fromJson(Map<String, dynamic> json) {
    src = json['src'];
    sizes = json['sizes'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['src'] = src;
    data['sizes'] = sizes;
    data['type'] = type;
    return data;
  }
}

class RelatedApplications {
  String? platform;
  String? url;

  RelatedApplications({this.platform, this.url});

  RelatedApplications.fromJson(Map<String, dynamic> json) {
    platform = json['platform'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['platform'] = platform;
    data['url'] = url;
    return data;
  }
}
