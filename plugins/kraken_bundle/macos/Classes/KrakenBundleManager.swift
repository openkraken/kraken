/*
* Copyright (C) 2019-present Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

import Cocoa
import FlutterMacOS

public class KrakenBundleManager: NSObject {
  private static let instance:KrakenBundleManager = KrakenBundleManager()
  private var bundleUrl:String?
  private var zipBundleUrl:String?
  private var bundlePath:String?
  private var krakenBundlePlugin:KrakenBundlePlugin?
  private var channel:FlutterMethodChannel?
  
  private override init() {
    bundleUrl = nil
    zipBundleUrl = nil
    bundlePath = nil
  }
  
  public static var shared: KrakenBundleManager {
      return self.instance
  }
  /**
   * page load form
   * priority bundleUrl > zipBundleUrl
   * @param bundleUrl
   * @param zipBundleUrl
   */
  public func setUp(bundleUrl:String? = nil, zipBundleUrl:String? = nil, bundlePath:String? = nil) {
    if (bundleUrl != nil) {
      self.bundleUrl = bundleUrl;
    }
    
    if (zipBundleUrl != nil) {
     self.zipBundleUrl = zipBundleUrl;
    }
    
    if (bundlePath != nil) {
      self.bundlePath = bundlePath
    }
  }

  public func getBundleUrl()->String? {
    return bundleUrl
  }

  public func getZipBundleUrl()->String? {
    return zipBundleUrl
  }
  
  public func getBundlePath()->String? {
    return bundlePath
  }

  public func reload() {
    if (self.krakenBundlePlugin != nil) {
      self.channel?.invokeMethod("reload", arguments: nil)
    }
  }

  public func onAttach(krakenBundlePlugin:KrakenBundlePlugin, channel:FlutterMethodChannel) {
    self.krakenBundlePlugin = krakenBundlePlugin
    self.channel = channel
  }
}
