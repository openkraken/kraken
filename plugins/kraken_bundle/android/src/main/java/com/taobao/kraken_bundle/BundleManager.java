package com.taobao.kraken_bundle;

public class BundleManager {

  private static BundleManager instance;

  private String bundleUrl;
  private String zipBundleUrl;
  private KrakenBundlePlugin krakenBundlePlugin;


  private BundleManager() {
  }


  public static BundleManager getInstance() {
    if (instance == null) {
      synchronized (BundleManager.class) {
        if (instance == null) {
          instance = new BundleManager();
        }
      }
    }
    return instance;
  }

  /**
   * page load form
   * priority bundleUrl > zipBundleUrl
   * @param bundleUrl
   * @param zipBundleUrl
   */
  public void setUp(String bundleUrl, String zipBundleUrl) {
    this.bundleUrl = bundleUrl;
    this.zipBundleUrl = zipBundleUrl;
  }

  public String getBundleUrl() {
    return "https://dev.g.alicdn.com/kraken/kraken-demos/long-list/build/kraken/index.js";
  }

  public String getZipBundleUrl() {
    return zipBundleUrl;
  }

  public void reload() {
    if (krakenBundlePlugin != null) {
      krakenBundlePlugin.reload();
    }
  }

  public void onAttach(KrakenBundlePlugin krakenBundlePlugin) {
    this.krakenBundlePlugin = krakenBundlePlugin;
  }

  public void onDetach() {
    this.krakenBundlePlugin = null;
  }

  public void destory() {
    instance = null;
  }
}
