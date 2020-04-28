/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

import 'dart:ui';

// https://w3c.github.io/manifest/
class AppManifest with KrakenManifest {
  String name;
  String shortName;
  String version;
  String startUrl;
  String display;
  String backgroundColor;
  String description;
  List<Icons> icons;
  List<RelatedApplications> relatedApplications;

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
      icons = new List<Icons>();
      json['icons'].forEach((v) {
        icons.add(new Icons.fromJson(v));
      });
    }
    if (json['related_applications'] != null) {
      relatedApplications = new List<RelatedApplications>();
      json['related_applications'].forEach((v) {
        relatedApplications.add(new RelatedApplications.fromJson(v));
      });
    }
    _parseKrakenManifestFromJson(json);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['short_name'] = this.shortName;
    data['version'] = this.version;
    data['start_url'] = this.startUrl;
    data['display'] = this.display;
    data['background_color'] = this.backgroundColor;
    data['description'] = this.description;
    if (this.icons != null) {
      data['icons'] = this.icons.map((v) => v.toJson()).toList();
    }
    if (this.relatedApplications != null) {
      data['related_applications'] =
          this.relatedApplications.map((v) => v.toJson()).toList();
    }

    _appendKrakenJson(data);

    return data;
  }
}

/// The extra definition of AppManifest, only works in kraken.
mixin KrakenManifest {
  /// Description of window size.
  Size size;

  /// Description of window title.
  String title;

  /// Description of window can be resized.
  bool resizeable;

  void _parseKrakenManifestFromJson(Map<String, dynamic> json) {
    title = json['title'];

    Map rawSize = json['size'];
    if (rawSize != null) {
      size = Size(rawSize['width'] ?? 0, rawSize['height'] ?? 0);
    }

    var _resizeable = json['resizeable'];
    if (_resizeable is String)
      resizeable = _resizeable == 'true';
    else if (_resizeable is bool) resizeable = _resizeable;
  }

  void _appendKrakenJson(Map<String, dynamic> data) {
    Map<String, double> _size = {'width': size.width, 'height': size.height};
    data['size'] = _size;
    data['title'] = title;
    data['resizeable'] = resizeable;
  }
}

class Icons {
  String src;
  String sizes;
  String type;

  Icons({this.src, this.sizes, this.type});

  Icons.fromJson(Map<String, dynamic> json) {
    src = json['src'];
    sizes = json['sizes'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['src'] = this.src;
    data['sizes'] = this.sizes;
    data['type'] = this.type;
    return data;
  }
}

class RelatedApplications {
  String platform;
  String url;

  RelatedApplications({this.platform, this.url});

  RelatedApplications.fromJson(Map<String, dynamic> json) {
    platform = json['platform'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['platform'] = this.platform;
    data['url'] = this.url;
    return data;
  }
}
