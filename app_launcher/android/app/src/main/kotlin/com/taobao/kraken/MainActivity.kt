package com.taobao.kraken.app_launcher

import android.os.Bundle
import androidx.annotation.NonNull
import com.taobao.kraken.Kraken
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    // getFlutterEngine 方法必须在 super.onCreate() 之后
    // getFlutterEngine 方法必须在 super.onCreate() 之后
    val kraken = Kraken(flutterEngine)
    // 这里的 url 可以换成业务 bundle
    // 这里的 url 可以换成业务 bundle
    val url = "https://dev.g.alicdn.com/kraken/kraken-demos/richtext/build/kraken/index.js"
    kraken.loadUrl(url)
  }

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
