#
# Generated file, do not edit.
#

Pod::Spec.new do |s|
  s.name             = 'FlutterPluginRegistrant'
  s.version          = '0.0.1'
  s.summary          = 'Registers plugins with your flutter app'
  s.description      = <<-DESC
Depends on all your plugins, and provides a function to register them.
                       DESC
  s.homepage         = 'https://flutter.dev'
  s.license          = { :type => 'BSD' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.ios.deployment_target = '8.0'
  s.source_files =  "Classes", "Classes/**/*.{h,m}"
  s.source           = { :path => '.' }
  s.public_header_files = './Classes/**/*.h'
  s.static_framework    = true
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.dependency 'Flutter'
  s.dependency 'connectivity'
  s.dependency 'device_info'
  s.dependency 'kraken_audioplayers'
  s.dependency 'kraken_camera'
  s.dependency 'kraken_geolocation'
  s.dependency 'kraken_method_channel'
  s.dependency 'kraken_sdk'
  s.dependency 'kraken_video_player'
  s.dependency 'kraken_webview'
  s.dependency 'path_provider'
  s.dependency 'shared_preferences'
end
