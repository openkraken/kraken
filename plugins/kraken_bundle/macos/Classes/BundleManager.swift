//
//  BundleManager.swift
//  kraken_bundle
//
//  Created by lzl on 2020/3/27.
//

import Cocoa
import FlutterMacOS

public class BundleManager: NSObject {
  private static let instance:BundleManager = BundleManager()
  private var bundleUrl:String?
  private var zipBundleUrl:String?
  private weak var krakenBundlePlugin:KrakenBundlePlugin?
  private weak var channel:FlutterMethodChannel?
  
  private override init() {
    bundleUrl = nil
    zipBundleUrl = nil
  }
  
  public static var shared: BundleManager {
      return self.instance
  }
  /**
   * page load form
   * priority bundleUrl > zipBundleUrl
   * @param bundleUrl
   * @param zipBundleUrl
   */
  public func setUp(bundleUrl:String, zipBundleUrl:String) {
    self.bundleUrl = bundleUrl;
    self.zipBundleUrl = zipBundleUrl;
  }

  public func getBundleUrl()->String? {
    return bundleUrl
  }

  public func getZipBundleUrl()->String? {
    return zipBundleUrl;
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
